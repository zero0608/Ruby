class AddWarehouseDataToInventoryHistory < ActiveRecord::Migration[6.1]
  def change
    add_reference :inventory_histories, :warehouse, foreign_key: true
    add_column :inventory_histories, :warehouse_adjustment, :integer
    add_column :inventory_histories, :warehouse_quantity, :integer
  end
end
