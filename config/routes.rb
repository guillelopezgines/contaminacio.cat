Rails.application.routes.draw do
  post '/', to: 'home#filter', as: 'filter'
  get '/location', to: 'home#location', as: 'location'
  get '/barcelona', to: 'home#barcelona', as: 'barcelona'
  get '/barcelona/:pollutant', to: 'home#barcelona_with_pollutant'
  get '/:pollutant', to: 'home#index_with_pollutant'
  get '/:pollutant/:location', to: 'home#index_with_pollutant_and_location'
  root 'home#index'
end
