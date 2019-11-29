include ActionView::Helpers::DateHelper

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:school_filter]

  def index
    @logs = @location.logs.where(pollutant: @pollutant).order(registered_at: :desc)
  end

  def schools
    query = "select 
            distinct district as name,
            district_handle as handle
          from locations 
          where district_handle IS NOT NULL 
          order by district"
    @districts = ActiveRecord::Base.connection.execute(query)

    query = "select registered_at from logs left join locations 
             on logs.location_id = locations.id
             where category = 'SCHOOL'
             order by registered_at limit 1"
    result = ActiveRecord::Base.connection.execute(query)
    @date = DateTime.parse(result[0]["registered_at"])

    if @year == '2018'
      query = "select
          historics.value as mean,
          locations.id,
          locations.name,
          locations.adhered,
          locations.district,
          locations.latitude,
          locations.longitude,
          locations.is_kindergarden,
          locations.is_primary_school,
          locations.is_secondary_school,
          locations.is_high_school,
          locations.is_special_school
        from historics
        left join locations
        on historics.location_id = locations.id
        where category = 'SCHOOL'
        #{ @district_handle ? "and district_handle = '#{@district_handle}'" : "" }
        #{ @filter_by_level }
        order by mean desc, name;"
    else
      query = "select
              count(*) as count,
              round(avg(value),2) as mean,
              locations.id,
              locations.name,
              locations.adhered,
              locations.district,
              locations.latitude,
              locations.longitude,
              locations.is_kindergarden,
              locations.is_primary_school,
              locations.is_secondary_school,
              locations.is_high_school,
              locations.is_special_school
            from logs
            left join locations
            on logs.location_id = locations.id
            where category = 'SCHOOL'
            and extract(hour from registered_at) >= 9
            and extract(hour from registered_at) < 17
            and extract(dow from registered_at) != 0
            and extract(dow from registered_at) != 6
            #{ @district_handle ? "and district_handle = '#{@district_handle}'" : "" }
            #{ @filter_by_level }
            group by locations.id
            order by mean desc, name;
          "
    end

    @schools = ActiveRecord::Base.connection.execute(query)
    @colors = []

    @schools.each do |school|
      mean = school["mean"].to_f
      @colors << get_color(mean)
    end

    @levels = [["infantil", "infantil"], ["primària", "primaria"], ["secundària", "secundaria"], ["batxillerat", "batxillerat"], ["educació especial", "educacio-especial"]]
    @level_name = @levels.select {|level| level[1] == @level }.first
    @period = (@year == '2018' ? " l'any 2018" : "")
    @title = "Nivells de contaminació atmosfèrica a les escoles #{@level_name ? (@level_name[0] =~ /^[aeiou]/i ? "d'" : "de ") + "#{@level_name[0]} " : ""}#{(@district ? (@district == 'Eixample' ? "de l'#{@district}" : (@district == 'Horta-Guinardó' ? "d'#{@district}" : "de #{@district}")) : "de Barcelona")}#{@period}"
    @period = (@year == '2018' ? "de l'any 2018" : "dels últims #{((Time.now - @date)/ 1.day).to_i} dies")
    @headline = "Segons les dades #{@period}, #{@schools.select{|s| s["mean"].to_f > 40.0}.count} de les #{@schools.count} escoles#{@level_name ? (@level_name[0] =~ /^[aeiou]/i ? " d'" : " de ") + "#{@level_name[0]} " : ""} #{(@district ? (@district == 'Eixample' ? "de l'#{@district}" : (@district == 'Horta-Guinardó' ? "d'#{@district}" : "de #{@district}")) : "de Barcelona")} (#{(100 * @schools.select{|s| s["mean"].to_f > 40.0}.count/@schools.count.to_f).round}%) superen, en horari escolar, els nivells de contaminació recomanats per la mitjana anual."
    @share = "#{@headline} Consulta si la teva escola és a la llista: contaminacio.cat#{request.original_fullpath}"
    @description = @headline

    respond_to do |format|
      format.html{
        render action: :schools
      }
      format.csv{
        require 'csv'
        csv_string = CSV.generate do |csv|
          csv << ["name", "district", "mean", "samples", "latitude", "longitude", "is_kindergarden", "is_primary_school", "is_secondary_school", "is_high_school", "is_special_education"]
          @schools.each do |school|
            csv << [school['name'], school['district'], school['mean'], school['count'], school['latitude'], school['longitude'], school['is_kindergarden'], school['is_primary_school'], school['is_secondary_school'], school['is_high_school'], school['is_special_school']]
          end
        end
        send_data csv_string, type: Mime::CSV, disposition: 'inline', filename: "escoles-#{@year == '2018' ? "#{@year}-" : ""}#{@district_handle ? "#{@district_handle}-" : ""}#{@level ? "#{@level}-" : ""}no2.csv"
      }
    end
  end

  def school
    @pollutant = Pollutant.find(1)
    @logs = @school.logs.where(pollutant: @pollutant).order(registered_at: :desc)
    values = @logs.map{|log| log.value }
    @mean = (values.sum / values.size.to_f).round(2)
    @color = get_color(@mean)

    respond_to do |format|
      format.html{
        render action: :school
      }
    end
  end

  def schools_by_district
    if location = Location.find_by_slug(params[:district])
      @school = location
      school()
    elsif location = Location.find_by_district_handle(params[:district])
      @district = location.district
      @district_handle = location.district_handle
      schools()
    else
      case params[:district]
      when 'infantil'
        @level = "infantil"
        @filter_by_level = "and is_kindergarden = true"
        schools()
      when 'primaria'
        @level = "primaria"
        @filter_by_level = "and is_primary_school = true"
        schools()
      when 'secundaria'
        @level = "secundaria"
        @filter_by_level = "and is_secondary_school = true"
        schools()
      when 'batxillerat'
        @level = "batxillerat"
        @filter_by_level = "and is_high_school = true"
        schools()
      when 'educacio-especial'
        @level = "educacio-especial"
        @filter_by_level = "and is_special_school = true"
        schools()
      else
        redirect_to action: "schools"
      end
    end
  end

  def schools_by_district_and_level
    case params[:level]
    when 'infantil'
      @level = "infantil"
      @filter_by_level = "and is_kindergarden = true"
    when 'primaria'
      @level = "primaria"
      @filter_by_level = "and is_primary_school = true"
    when 'secundaria'
      @level = "secundaria"
      @filter_by_level = "and is_secondary_school = true"
    when 'batxillerat'
      @level = "batxillerat"
      @filter_by_level = "and is_high_school = true"
    when 'educacio-especial'
      @level = "educacio-especial"
      @filter_by_level = "and is_special_school = true"
    end
    schools_by_district()
  end

  def schools_by_year
    @year = '2018'
    schools()
  end

  def schools_by_year_and_district
    @year = '2018'
    schools_by_district()
  end

  def schools_by_year_district_and_level
    @year = '2018'
    schools_by_district_and_level()
  end

  def index_with_pollutant
    if pollutant = params[:pollutant]
      if @pollutant = Pollutant.find_by_short_name(pollutant.upcase)
        session[:pollutant] = @pollutant.id
      end
    end
    redirect_to action: "index"
  end

  def index_with_pollutant_and_location
    if location = params[:location]
      if @location = Location.find_by_slug(location)
        session[:location] = @location.id
      end
    end
    redirect_to action: "index_with_pollutant"
  end

  def filter
    session[:location] = params[:location]
    session[:pollutant] = params[:pollutant]
    redirect_to :back
  end

  def school_filter
    if params[:school_level] == 'all'
      session.delete(:school_level)
    else
      session[:school_level] = params[:school_level]
    end
  end

  def location
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f
    min_distance = false
    location = false
    Location.stations.enabled.each do |l|
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

  def group
    begin
      group = params[:group]
      @locations = Location.stations.public_send("from_" + group)
      @group_name = group.titlecase
      render "home/group"
    rescue
      redirect_to action: "index"
    end
  end

  def group_with_pollutant
    if pollutant = params[:pollutant]
      if @pollutant = Pollutant.find_by_short_name(pollutant.upcase)
        session[:pollutant] = @pollutant.id
      end
    end
    redirect_to action: "group"
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

  def get_color mean
    if mean < 20.0
      return "#02b0f0"
    elsif mean < 40.0
      return "#92d050"
    elsif mean < 50.0
      return "#ffc003"
    elsif mean < 60.0
      return "#ff0200"
    else
      return "#c30000"
    end
  end

end
