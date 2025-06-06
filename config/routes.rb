Rails.application.routes.draw do
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in
  # application.html.erb)
  #
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "up" => "rails/health#show", :as => :rails_health_check

  # User routes
  get "/login", to: "users#login", as: :login
  post "/sign_in", to: "clearance/sessions#create", as: :sign_in
  delete "/logout", to: "users#logout", as: :logout

  resources :polls, only: [:create, :index], constraints: {id: /poll_.*/} do
    resources :votes, only: [:create, :index]
  end

  constraints id: /poll_.*/ do
    get "/:id/vote", to: "votes#new", as: :new_poll_vote
    get "/:id/votes/edit", to: "votes#edit", as: :edit_poll_vote
    patch "/:id/votes", to: "votes#update", as: :update_poll_votes
    get "/:id", to: "polls#show", as: :poll
  end

  root "polls#new", as: :new_poll
end
