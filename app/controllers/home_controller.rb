class HomeController < ApplicationController
  def index
    @logs = @location.logs.where(pollutant: @pollutant).order(registered_at: :desc)
  end

  def filter
    session[:location] = params[:location]
    session[:pollutant] = params[:pollutant]
    redirect_to :back
  end

  def location
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f
    min_distance = false
    location = false
    Location.all.each do |l|
      distance = distance([latitude, longitude], [l.latitude, l.longitude])
      if min_distance == false or distance < min_distance
        min_distance = distance
        location = l
      end
    end

    render json: {
      location: location.id
    }
  end

  def barcelona
    @locations = Location.where(city: 'Barcelona').order(name: :asc)
  end

  private

  def distance loc1, loc2
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c # Delta in meters
  end

end
