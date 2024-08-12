# frozen_string_literal: true

class Carton < ApplicationRecord
  belongs_to :product_variant, optional: true
  belongs_to :carton_detail, optional: true

  has_many :carton_locations, dependent: :destroy
end
