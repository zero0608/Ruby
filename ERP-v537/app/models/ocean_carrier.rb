class OceanCarrier < ApplicationRecord
  has_many :containers
  scope :set_store, ->(store) { where(store: store) }
end
