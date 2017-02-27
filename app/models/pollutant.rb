class Pollutant < ApplicationRecord
  has_many :logs, dependent: :destroy

  def name_with_short_name
    "#{name} (#{short_name})"
  end
end
