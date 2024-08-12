class WarehouseTransferOrder < ApplicationRecord
  belongs_to :from_warehouse, class_name: 'Warehouse', foreign_key: 'from_warehouse_id', required: true
  belongs_to :to_warehouse, class_name: 'Warehouse', foreign_key: 'to_warehouse_id', required: true
  has_many :warehouse_transfer_items, dependent: :destroy

  accepts_nested_attributes_for :warehouse_transfer_items, allow_destroy: true, reject_if: :all_blank

  enum status: { new_order: 0, in_production: 1, shipped: 2}, _default: :new_order

  after_create do
    name = "TF"+"#{self.from_warehouse.name.slice(0..3)}"+"#{self.to_warehouse.name.slice(0..3)}"+ "#{WarehouseTransferOrder.count.to_i + 1}"
    self.update(name: name)
  end
  
end
