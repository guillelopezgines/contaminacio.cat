class Pollutant < ApplicationRecord
  has_many :logs, dependent: :destroy
end
