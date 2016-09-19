class Log < ApplicationRecord

  belongs_to :location
  belongs_to :pollutant

  DEFAULT_LOCATION = "08019043"
  TIME_WINDOW = 1.week.ago.utc

  def tupla
    [registered_at.to_i * 1000, value]
  end

  def self.data
    Log.order(registered_at: :desc).map { |log| log.tupla }
  end

  def self.data_last_7_days
    Log.where("registered_at >= ?", TIME_WINDOW).order(registered_at: :desc).map { |log| log.tupla }
  end

  def self.destroy_old_ones
    Log.where("registered_at < ?", TIME_WINDOW).destroy_all()
  end

end
