Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "signup", to: "users#create"
      post "login", to: "auth#login"
      get "/teams/available", to: "teams#available"

      resources :teams do
        post "join", on: :member
        get "members", on: :member

        resources :channels do
          post "join", on: :member
          resources :messages
        end
        resources :memberships
      end

      resources :users
      resources :direct_messages
        get "direct_messages/conversation/:user_id", to: "direct_messages#conversation"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
