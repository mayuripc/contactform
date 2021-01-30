Rails.application.routes.draw do
 
  root  'home#index'
  resources :home, only: [:index, :new, :create]
  match '*unmatched', to: 'application#route_not_found', via: :all
  end