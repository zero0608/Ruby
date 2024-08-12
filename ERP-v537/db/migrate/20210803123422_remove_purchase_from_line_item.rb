class RemovePurchaseFromLineItem < ActiveRecord::Migration[6.1]
  def change
    remove_column :line_items, :purchase_quantity, :integer
  end
end
