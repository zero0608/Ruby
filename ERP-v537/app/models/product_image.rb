class ProductImage < ApplicationRecord
  belongs_to :product
  has_many :product_variants
end
