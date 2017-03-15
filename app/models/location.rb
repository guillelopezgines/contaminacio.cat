class Location < ApplicationRecord
  has_many :logs, dependent: :destroy

  scope :enabled, -> { where(enabled: true) }
  scope :from_barcelona, -> { where(city: 'Barcelona').order(name: :asc) }
  scope :from_catalunya, -> { all.order(name: :asc) }

  def description
    "#{city} - #{name}"
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
    pollutants = Pollutant.all

    pollutants.each do |p|
      if contaminants = json['contaminants']
        if contaminants.length > 0
          contaminants.each do |c|
            contaminant = c.second
            if contaminant['abreviatura'] == p.selector
              contaminant['dadesMesuresDiaria'].each_with_index do |val, index|
                value = val['valor']
                if index < 24 and value != ''
                  datetime = date.to_datetime.change({ hour: index})
                  previous_log = Log.where(location_id: self.id, pollutant_id: p.id)
                                    .where("registered_at < ?", datetime)
                                    .order(registered_at: :desc)
                                    .limit(1)
                                    .last
                  if previous_log.try(:registered_at).try(:year) == datetime.year
                    previous_annual_sum = previous_log.try(:annual_sum) || 0
                    previous_annual_registers = previous_log.try(:annual_registers) || 0
                  else
                    previous_annual_sum = 0
                    previous_annual_registers = 0
                  end
                  
                  Log.find_or_create_by(registered_at: datetime, pollutant_id: p.id, location_id: self.id) do |log|
                    if log
                      log.value = value.to_f
                      log.annual_sum = previous_annual_sum + log.value
                      log.annual_registers = previous_annual_registers + 1
                      puts "#{p.name} - #{self.name} - #{datetime} - #{value} - #{log.annual_sum} - #{log.annual_registers}"
                    else
                      puts "No log! For registered_at: #{datetime}, pollutant_id: #{p.id} and location_id: #{self.id}"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def self.record_all
    Location.enabled.each do |location|
      # location.record Date.yesterday
      location.record Date.today
    end
  end

  def self.barcelona_tweet_update
    locations = []
    pollutant = Pollutant.find_by_short_name("NO2")
    Location.enabled.from_barcelona.each do |location|
      locations << "#{location.name.split('-').last}: #{location.logs.where(pollutant: pollutant).order(registered_at: :desc).first.value.to_i}"
    end
    "#{(Log.last.registered_at - 1.hour).strftime("%Hh")} - NO² (µg/m³): #{locations.join(", ")}"
  end

end
