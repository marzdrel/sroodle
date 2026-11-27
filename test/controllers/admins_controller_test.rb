require "test_helper"

class AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = polls(:one)
  end

  test "the admin link shows the organizer page" do
    get poll_admin_path(@poll, token: @poll.admin_token)

    assert_response :success
    assert_equal "Poll/Admin", inertia_component
    assert_equal "http://www.example.com/#{@poll.to_param}", inertia_props.dig("links", "public")
    assert_equal 2, inertia_props["participants_count"]
  end

  test "a wrong admin token is not found" do
    get poll_admin_path(@poll, token: polls(:two).admin_token)

    assert_response :not_found
  end
end
