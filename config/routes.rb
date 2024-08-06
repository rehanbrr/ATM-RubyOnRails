Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :accounts, param: :account_number do
    resources :transactions
    member do
      get 'withdraw'
      post 'withdraw', to: 'accounts#do_withdraw'
      get 'deposit'
      post 'deposit', to: 'accounts#do_deposit'
      get 'verify_pin'
      post 'verify_pin', to: 'accounts#check_pin'
      get 'send_money'
      post 'send_money', to: 'account#transfer_money'
      post 'change_status'
    end
  end

  root 'home#index'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
