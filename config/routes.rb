Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: "api/v1/users/sessions",
        registrations: "api/v1/users/registrations",
        confirmations: "api/v1/users/confirmations",
        unlocks: "api/v1/users/unlocks"
      }

      resources :openai, only: :create
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
