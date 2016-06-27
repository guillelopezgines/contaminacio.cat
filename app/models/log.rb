class Log < ApplicationRecord

  belongs_to :location
  belongs_to :pollutant

  DEFAULT_LOCATION = "08019043"

  def tupla
    [registered_at.to_i * 1000, value]
  end

  def self.data
    Log.order(registered_at: :desc).map { |log| log.tupla }
  end

end
