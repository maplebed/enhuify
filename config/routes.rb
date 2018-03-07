Rails.application.routes.draw do
  root 'bulbs#index'
  resources :bulbs
  # For details on the DSL available within this file, see
  # http://guides.rubyonrails.org/routing.html
  get '/bulbs/:id/random', to: 'bulbs#random'
  get '/bulbs/:id/set/:hue/:sat/:bri', to: 'bulbs#set'
end

