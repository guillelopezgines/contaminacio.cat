class HomeController < ApplicationController
  def index
    @logs = @location.logs.order(registered_at: :desc)
  end

  def filter
    session[:location] = params[:location]
    redirect_to root_url
  end

end
