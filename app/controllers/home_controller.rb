class HomeController < ApplicationController
  def index
    @median = Log.average(:value).round(2)
  end

end
