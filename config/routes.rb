Rails.application.routes.draw do
  post '/', to: 'home#filter', as: 'filter'
  get '/location', to: 'home#location', as: 'location'
  get '/:group', to: 'home#group'
  get '/:group/:pollutant', to: 'home#group_with_pollutant'
  get '/:pollutant/:location', to: 'home#index_with_pollutant_and_location'
  root 'home#index'
end
