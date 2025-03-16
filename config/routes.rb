Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "api/v1/users/sessions",
    registrations: "api/v1/users/registrations",
    confirmations: "api/v1/users/confirmations",
    unlocks: "api/v1/users/unlocks"
  }

  root to: "home#index"

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :openai, only: :create
    end
  end
end
