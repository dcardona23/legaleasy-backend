Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, path_names: {
        sign_in: "login",
        sign_out: "logout",
        registration: "signup"
      },
      controllers: {
        sessions: "users/sessions",
        registrations: "users/registrations"
      }
      resources :openai, only: :create
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
