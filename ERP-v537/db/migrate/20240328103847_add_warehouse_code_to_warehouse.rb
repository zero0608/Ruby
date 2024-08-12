class AddWarehouseCodeToWarehouse < ActiveRecord::Migration[6.1]
  def change
    add_column :warehouses, :code, :string
  end
end
