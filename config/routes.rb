Rails.application.routes.draw do
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
   
  # Silence Chrome DevTools requests
  get "/.well-known/*path", to: proc { [404, {}, ['']] }

  root "home#index"

  namespace :api, defaults: { format: :json } do
  post 'login', to: 'auth#login'
    resources :users
    resources :books
    resources :borrowings, only: [:index, :create] do
      member do
        post :return_book
      end
      collection do
        get :overdue
      end
    end

    namespace :dashboard do
      get :summary
      get :availability
    end
  end

  # Catch-all route for React SPA (must be last). Sends all non-AJAX, HTML requests
  # that are not to /api or asset paths back to home#index so the client router handles them.
  get '*path', to: 'home#index', constraints: lambda { |req|
    req.format.html? && !req.xhr? && !req.path.start_with?('/rails/', '/api/')
  }
end
