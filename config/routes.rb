Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      get "/merchants/find", to: "merchants/find#show"
      get "/items/find_all", to: "items/find#index"
      
      resources :merchants, only: [:index, :show] do
        resources :items, only: :index, controller: "merchant_items"
      end

      resources :items do
        get "/merchant", to: "item_merchant#show"
      end
    end
  end
end
