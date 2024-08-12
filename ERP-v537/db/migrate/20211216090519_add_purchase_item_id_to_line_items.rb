class AddPurchaseItemIdToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :purchase_id, :integer
    add_column :line_items, :purchase_item_id, :integer
  end
end
