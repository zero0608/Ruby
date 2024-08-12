class AddStoreIdToWarehouse < ActiveRecord::Migration[6.1]
  def change
    add_reference :warehouses, :store_address, foreign_key: true
    add_reference :warehouses, :tax_rate, foreign_key: true
  end
end
