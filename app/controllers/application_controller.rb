class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_location

  def set_location
    @location = (session[:location] ? Location.find(session[:location]) : Location.find_by_code(Log::DEFAULT_LOCATION))
  end
end
