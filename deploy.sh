#!/bin/bash
set -e

# Source .env file if it exists
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="sroodle"
IMAGE_TAG="latest"
REGISTRY="${APP_REGISTRY:-}"
RELEASE_NAME="sroodle"
NAMESPACE="sroodle"
PLATFORM="linux/amd64"
DOMAIN="${APP_DOMAIN}"

# Action flags
ACTION=""
SKIP_BUILD=false
SKIP_DB_SETUP=false

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    echo "Usage: $0 [ACTION] [OPTIONS]"
    echo
    echo "Actions:"
    echo "  deploy        Deploy the application (default)"
    echo
    echo "Options:"
    echo "  --registry REGISTRY     Container registry (default: APP_REGISTRY env var)"
    echo "  --domain DOMAIN         Application domain (required: APP_DOMAIN env var)"
    echo "  --namespace NAMESPACE   Kubernetes namespace (default: sroodle)"
    echo "  --release-name NAME     Helm release name (default: sroodle)"
    echo "  --tag TAG              Image tag (default: latest)"
    echo "  --platform PLATFORM    Build platform (default: linux/amd64)"
    echo "  --skip-build           Skip building and pushing image"
    echo "  --skip-db-setup        Skip database setup"
    echo "  --help                 Show this help message"
    echo
    echo "Examples:"
    echo "  $0 deploy                    # Deploy with defaults"
    echo "  $0 deploy --skip-build       # Deploy without building image"
    echo "  $0 deploy --tag v1.0.0       # Deploy with specific tag"
}


# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi

    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi

    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed or not in PATH"
        exit 1
    fi

    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi

    if [ ! -f "config/master.key" ]; then
        print_error "config/master.key not found. Make sure you're in the Rails app directory."
        exit 1
    fi

    if [ -z "${DOMAIN}" ]; then
        print_error "APP_DOMAIN environment variable is required"
        exit 1
    fi

    print_success "All prerequisites met"
}

# Build and push container image
build_and_push_image() {
    if [ "$SKIP_BUILD" = true ]; then
        print_status "Skipping build and push as requested"
        return
    fi

    print_status "Building container image for platform: ${PLATFORM}..."

    if ! docker build --platform ${PLATFORM} -t ${IMAGE_NAME}:${IMAGE_TAG} .; then
        print_error "Failed to build Docker image"
        exit 1
    fi

    print_status "Tagging image for registry..."
    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

    print_status "Pushing image to registry..."
    if ! docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}; then
        print_warning "Failed to push to registry. Continuing with local image..."
        REGISTRY=""
    else
        print_success "Image pushed successfully"
    fi
}

# Create namespace and service account
create_namespace() {
    print_status "Creating namespace if it doesn't exist..."

    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -


    print_success "Namespace created/updated"
}

# Deploy with Helm
deploy_with_helm() {
    print_status "Deploying with Helm..."

    local image_repo="${REGISTRY}/${IMAGE_NAME}"
    if [ -z "${REGISTRY}" ]; then
        image_repo="${IMAGE_NAME}"
    fi

    local rails_master_key=$(cat config/master.key)

    helm upgrade --install ${RELEASE_NAME} ./charts \
        --set image.repository=${image_repo} \
        --set image.tag=${IMAGE_TAG} \
        --set ingress.enabled=true \
        --set ingress.hosts[0].host=${DOMAIN} \
        --set ingress.hosts[0].paths[0].path=/ \
        --set ingress.hosts[0].paths[0].pathType=Prefix \
        --set railsMasterKey="${rails_master_key}" \
        --namespace=${NAMESPACE} \
        --wait \
        --timeout=5m

    print_success "Helm deployment completed"
}

# Wait for deployment to be ready (migrations handled by helm hook)
setup_database() {
    if [ "$SKIP_DB_SETUP" = true ]; then
        print_status "Skipping database setup as requested"
        return
    fi

    print_status "Waiting for deployment to be ready..."

    # Wait for the deployment specifically, not individual pods
    if ! kubectl wait --for=condition=available deployment/sroodle \
        --namespace=${NAMESPACE} --timeout=300s; then
        print_error "Deployment failed to become ready"
        kubectl get pods -l app.kubernetes.io/name=sroodle --namespace=${NAMESPACE}
        exit 1
    fi

    print_success "Deployment ready - migrations completed successfully by helm hook"
}

# Display access information
show_access_info() {
    print_success "Deployment completed successfully!"
    echo
    print_status "Access information:"
    echo "  • Port forward: kubectl port-forward service/sroodle 8080:80 -n ${NAMESPACE}"
    echo "  • Then visit: http://localhost:8080"
    echo
    print_status "Useful commands:"
    echo "  • Check pods: kubectl get pods -l app.kubernetes.io/name=sroodle -n ${NAMESPACE}"
    echo "  • View logs: kubectl logs -l app.kubernetes.io/name=sroodle -n ${NAMESPACE}"
    echo "  • Rails console: kubectl exec -it deployment/sroodle -n ${NAMESPACE} -- bin/rails console"
    echo "  • Uninstall: helm uninstall ${RELEASE_NAME} -n ${NAMESPACE}"
    echo
}

# Error cleanup function
error_cleanup() {
    if [ $? -ne 0 ]; then
        print_error "Operation failed!"
        echo
        print_status "Troubleshooting:"
        echo "  • Check pod status: kubectl get pods -l app.kubernetes.io/name=sroodle -n ${NAMESPACE}"
        echo "  • Check pod logs: kubectl logs -l app.kubernetes.io/name=sroodle -n ${NAMESPACE}"
        echo "  • Check events: kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp'"
    fi
}

# Set trap for cleanup
trap error_cleanup EXIT

# Main deployment function
deploy() {
    echo "🚀 Deploying Sroodle to k3s"
    echo "================================"

    check_prerequisites
    build_and_push_image
    create_namespace
    deploy_with_helm
    setup_database
    show_access_info
}


# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        deploy)
            ACTION="$1"
            shift
            ;;
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --release-name)
            RELEASE_NAME="$2"
            shift 2
            ;;
        --tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-db-setup)
            SKIP_DB_SETUP=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Default action is deploy
if [ -z "$ACTION" ]; then
    ACTION="deploy"
fi

# Execute the requested action
case $ACTION in
    deploy)
        deploy
        ;;
    *)
        print_error "Unknown action: $ACTION"
        show_usage
        exit 1
        ;;
esac
