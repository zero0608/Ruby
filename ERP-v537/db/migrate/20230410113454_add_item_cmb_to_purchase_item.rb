class AddItemCmbToPurchaseItem < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_items, :item_cbm, :float
  end
end
