Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  resources :polls, only: [:create, :index]

  constraints id: /poll_[^\/]+/ do
    get "/:id", to: "polls#show", as: :poll

    get "/:id/vote", to: "votes#new", as: :new_poll_vote
    post "/:id/votes", to: "votes#create", as: :poll_votes
    get "/:id/votes/edit", to: "votes#edit", as: :edit_poll_vote
    patch "/:id/votes", to: "votes#update", as: :update_poll_votes

    get "/:id/p/:token", to: "participants#show", as: :participant_link

    get "/:id/admin/:token", to: "admins#show", as: :poll_admin
  end

  root "polls#new", as: :new_poll
end
