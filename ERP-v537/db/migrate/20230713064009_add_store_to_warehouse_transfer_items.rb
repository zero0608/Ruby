class AddStoreToWarehouseTransferItems < ActiveRecord::Migration[6.1]
  def change
    add_column :warehouse_transfer_items, :store, :string
  end
end
