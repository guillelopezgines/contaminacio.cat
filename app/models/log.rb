class Log < ApplicationRecord

  def tupla
    [registered_at.to_i * 1000, value]
  end

  def self.data
    Log.order(registered_at: :desc).map { |log| log.tupla }
  end

  def self.record
    Log.save(Date.yesterday)
    Log.save(Date.today)
  end

  private

  def self.save(date)
    require 'open-uri'
    require 'json'
    
    code = "08019043"
    date = "#{date.day}/#{date.month}/#{date.year}"
    url = "http://dtes.gencat.cat/icqa/AppJava/getDadesDiaries.do?codiEOI=#{code}&data=#{date}"
    data = open(url).read
    data = data.to_s.gsub!('\'','"')
    json = JSON.parse(data)
    date = json['data'].to_date
    json['contaminants']['contaminant3']['dadesMesuresDiaria'].each_with_index do |val, index|
      value = val['valor']
      if index < 24 and value != ''
        datetime = date.to_datetime.change({ hour: index})
        Log.find_or_create_by(registered_at: datetime) do |log|
          log.value = value
        end
      end
    end
  end
end
