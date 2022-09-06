Rails.application.routes.draw do  
  root 'static_pages#home'
  
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'

  get '/signup', to: 'users#new'
  
  resources :users
  
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :account_activations, only: [:edit]
  #get'/account_activations/トークン/edit' to:  xxx#editが有効になって、 
  #名前付きルート
  #edit_account_activation_url(token)が使える


end

