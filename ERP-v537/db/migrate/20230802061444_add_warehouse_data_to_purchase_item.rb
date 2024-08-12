class AddWarehouseDataToPurchaseItem < ActiveRecord::Migration[6.1]
  def change
    add_reference :purchase_items, :warehouse, foreign_key: true, null: true
    add_column :purchase_items, :state, :string
  end
end
