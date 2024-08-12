class LocationHistory < ApplicationRecord
  belongs_to :product_variant
  belongs_to :product_location, optional: true
  belongs_to :user
end
