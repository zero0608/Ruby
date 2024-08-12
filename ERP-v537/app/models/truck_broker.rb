class TruckBroker < ApplicationRecord
  has_many :carriers
  has_many :shipping_quotes, dependent: :destroy
end