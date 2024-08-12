class AddStatusToPurchaseItem < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_items, :status, :integer
  end
end
