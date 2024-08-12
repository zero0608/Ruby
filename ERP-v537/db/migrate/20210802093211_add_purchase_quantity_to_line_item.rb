class AddPurchaseQuantityToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :purchase_quantity, :integer
  end
end
