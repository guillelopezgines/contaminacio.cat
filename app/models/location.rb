class Location < ApplicationRecord
  has_many :logs, dependent: :destroy

  scope :from_barcelona, -> { where(city: 'Barcelona').order(name: :asc) }

  def description
    "#{city} - #{name}"
  end

  def self.record_all
    Location.all.each do |location|
      location.record Date.yesterday
      location.record Date.today
    end
  end

  def record(date)
    require 'open-uri'
    require 'json'

    date = "#{date.day}/#{date.month}/#{date.year}"
    url = "http://dtes.gencat.cat/icqa/AppJava/getDadesDiaries.do?codiEOI=#{self.code}&data=#{date}"
    data = open(url).read
    data = data.to_s.gsub!('\'','"')
    json = JSON.parse(data)
    date = json['data'].to_date

    Pollutant.all.each do |p|
      if contaminants = json['contaminants']
        if contaminants.length > 0
          contaminants.each do |c|
            contaminant = c.second
            if contaminant['abreviatura'] == p.selector
              contaminant['dadesMesuresDiaria'].each_with_index do |val, index|
                value = val['valor']
                if index < 24 and value != ''
                  datetime = date.to_datetime.change({ hour: index})
                  Log.find_or_create_by(registered_at: datetime, pollutant_id: p.id, location_id: self.id) do |log|
                    log.value = value
                    puts "#{p.name} - #{self.name} - #{datetime} - #{value}"
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def self.barcelona_tweet_update
    locations = []
    pollutant = Pollutant.find_by_short_name("NO2")
    Location.from_barcelona.each do |location|
      locations << "#{location.name.split('-').last}: #{location.logs.where(pollutant: pollutant).order(registered_at: :desc).first.value.to_i}"
    end
    "#{(Log.last.registered_at - 1.hour).strftime("%Hh")} - NO² (µg/m³): #{locations.join(", ")}"
  end

end
