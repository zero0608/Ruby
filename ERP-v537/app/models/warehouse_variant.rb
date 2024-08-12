class WarehouseVariant < ApplicationRecord
  belongs_to :product_variant
  belongs_to :product_variant_location, optional: true
  belongs_to :warehouse
end
