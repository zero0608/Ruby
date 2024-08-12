class ProductVariantLocation < ApplicationRecord
  belongs_to :product_location, optional: true
  belongs_to :product_variant, optional: true

  has_many :carton_locations
end