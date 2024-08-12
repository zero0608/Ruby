class AddTransferOrderIdToItems < ActiveRecord::Migration[6.1]
  def change
    add_reference :warehouse_transfer_items, :warehouse_transfer_order, foreign_key: true, null: true
  end
end
