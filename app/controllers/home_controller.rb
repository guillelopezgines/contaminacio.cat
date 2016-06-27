class HomeController < ApplicationController
  def index
    @logs = @location.logs.where(pollutant: @pollutant).order(registered_at: :desc)
  end

  def filter
    session[:location] = params[:location]
    session[:pollutant] = params[:pollutant]
    redirect_to root_url
  end

end
