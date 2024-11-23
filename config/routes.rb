require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products

  resource :cart, only: [:create, :show] do
    patch 'add_item', on: :collection
    delete ':product_id', to: 'carts#remove_cart_item', on: :member
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
