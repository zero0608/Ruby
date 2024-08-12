class WarehouseTransferItem < ApplicationRecord
  belongs_to :product_variant
  belongs_to :warehouse_variant, optional: true
  belongs_to :warehouse_transfer_order, optional: true
end
