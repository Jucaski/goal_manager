Rails.application.routes.draw do
  get "balances/index"
  resources :day_habits

  resources :habits do
    collection do
      post :submit_ratings
      patch :update_order
    end
  end

  devise_for :users
  # get "dashboard/best_to"
  root "home#index"
  get 'settings', to: 'dashboard#settings'
  get 'best', to: 'dashboard#best_to'

  get 'balance', to: 'balances#index', as: 'balance'
  post 'balance/create_entry', to: 'balances#create_entry', as: 'create_entry'

  get 'balance/:id/edit', to: 'balances#edit', as: 'edit_balance_entry'
  patch 'balance/:id', to: 'balances#update', as: 'balance_entry'


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
