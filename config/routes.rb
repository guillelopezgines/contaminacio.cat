Rails.application.routes.draw do

  post '/', to: 'home#filter', as: 'filter'
  get '/location', to: 'home#location', as: 'location'
  get '/barcelona', to: 'home#barcelona', as: 'barcelona'
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
