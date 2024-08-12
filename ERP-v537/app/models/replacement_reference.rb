class ReplacementReference < ApplicationRecord
  has_many :line_items, dependent: :nullify
  belongs_to :product_variant, optional: true
end