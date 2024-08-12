class AddStoreToWarehouses < ActiveRecord::Migration[6.1]
  def change
    add_column :warehouses, :store, :string
  end
end
