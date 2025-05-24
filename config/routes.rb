Rails.application.routes.draw do
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in
  # application.html.erb)
  #
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "up" => "rails/health#show", :as => :rails_health_check

  resources :polls, only: [:new, :create, :index]

  constraints id: /poll_.*/ do
    get "/:id", to: "polls#show", as: :poll
  end

  root "polls#new"
end
