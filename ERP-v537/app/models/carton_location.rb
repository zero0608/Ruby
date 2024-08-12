# frozen_string_literal: true

class CartonLocation < ApplicationRecord
  belongs_to :carton, optional: true
  belongs_to :product_location, optional: true

  has_many :product_variant_locations
end
