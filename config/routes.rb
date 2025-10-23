Rails.application.routes.draw do
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Reset password logic
  get    "password_reset/new",      to: "sessions#reset_password_form", as: "reset_password_form"
  post   "password_reset/create",   to: "sessions#send_reset_password", as: "send_reset_password"
  get    "password_reset/verify",   to: "sessions#verify",              as: "verify_password_reset"
  post   "password_reset/check",    to: "sessions#check",               as: "check_password_reset"
  get    "password_reset/edit",     to: "sessions#edit",                as: "edit_password_reset"
  patch  "password_reset/update",   to: "sessions#update",              as: "password_reset_update"

  resources :users, only: [:index, :edit, :update, :new, :create, :destroy]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  get '*unmatched_route', to: 'sessions#new', as: 'catch_all'
end
