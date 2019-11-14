Rails.application.routes.draw do
  root 'home#index'
  get '/escoles', to: 'home#schools', as: "schools"
  get '/escoles/2018', to: 'home#schools_by_year', as: 'schools_by_year'
  get '/escoles/2018/:district', to: 'home#schools_by_year_and_district', as: 'schools_by_year_and_district'
  get '/escoles/2018/:district/:level', to: 'home#schools_by_year_district_and_level', as: 'schools_by_year_district_and_level'
  get '/escoles/:district', to: 'home#schools_by_district', as: 'schools_by_district'
  get '/escoles/:district/:level', to: 'home#schools_by_district_and_level', as: 'schools_by_district_and_level'
  get '/location', to: 'home#location', as: 'location'
  get '/:group', to: 'home#group'
  get '/:group/:pollutant', to: 'home#group_with_pollutant'
  get '/:pollutant/:location', to: 'home#index_with_pollutant_and_location'
  post '/', to: 'home#filter', as: 'filter'
  post '/escoles', to: 'home#school_filter', as: 'school_filter'
end
