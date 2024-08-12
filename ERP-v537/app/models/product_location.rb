class ProductLocation < ApplicationRecord
  has_many :product_variant_locations, dependent: :destroy
  has_many :location_histories, dependent: :destroy
  has_many :carton_locations
  
  accepts_nested_attributes_for :product_variant_locations
end