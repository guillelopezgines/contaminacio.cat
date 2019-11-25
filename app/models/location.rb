class Location < ApplicationRecord
  has_many :logs, dependent: :destroy

  TYPE_STATION = "STATION"
  TYPE_SCHOOL = "SCHOOL"

  scope :enabled, -> { where(enabled: true) }
  scope :stations, -> { where(category: TYPE_STATION) }
  scope :schools, -> { where(category: TYPE_SCHOOL) }
  scope :from_barcelona, -> { where(city: 'Barcelona').order(name: :asc) }
  scope :from_catalunya, -> { all.order(name: :asc) }

  def description
    "#{city} - #{name}"
  end

  def self.record_all
    require 'open-uri'
    require 'json'

    date = Date.today
    url = "http://mediambient.gencat.cat/web/shared/json/quaire/estat_#{date.strftime("%Y%m%d")}.json"
    data = open(url).read
    json = JSON.parse(data)
    features = json["features"]

    features.each do |feature|
      if location = Location.find_by_code(feature["id"])
        if properties = feature["properties"]
          if contaminants = properties["contaminants"]
            if contaminants.length > 0
                location.record(date, contaminants)
            end
          end
        end
      end
    end
  end

  def record(date, data)
    Pollutant.all.each do |p|
      data.each do |contaminant|
        if contaminant['abbr'] == p.selector
          contaminant['dadesHoraries'].each_with_index do |val, index|
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

              if log = Log.find_or_create_by(registered_at: datetime, pollutant_id: p.id, location_id: self.id)
                log.value = value.to_f
                log.annual_sum = previous_annual_sum + log.value
                log.annual_registers = previous_annual_registers + 1
                log.save
                puts "#{p.name} - #{self.name} - #{datetime} - #{value} - #{log.annual_sum} - #{log.annual_registers}"
              end
            end
          end
        end
      end
    end
  end

  def self.barcelona_tweet_update
    locations = []
    pollutant = Pollutant.find_by_short_name("NO₂")
    Location.stations.enabled.from_barcelona.each do |location|
      if value = location.logs.where(pollutant: pollutant).order(registered_at: :desc).try(:first).try(:value).try(:to_i)
        if value > 0
          icon = (value > 40 ? "🔴": "⚪️")
          exclamation = (value >= 150 ? "‼️" : (value >= 100 ? "❗️" : ""))
          locations << "#{icon} #{location.name.split('-').last.strip}: #{value}#{exclamation}"
        end
      end
    end
    if locations.length > 0
      return "#{(Log.last.registered_at).strftime("%Hh")} - NO₂ (µg/m³):\n#{locations.join("\n")}"
    else
      return false
    end
  end

end
