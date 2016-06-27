Rails.application.routes.draw do

  post '/', to: 'home#filter', as: 'filter'
  get '/location', to: 'home#location', as: 'location'
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
