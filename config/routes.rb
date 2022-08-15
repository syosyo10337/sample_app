Rails.application.routes.draw do
  get 'static_pages home/help'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'application#hello'
end
