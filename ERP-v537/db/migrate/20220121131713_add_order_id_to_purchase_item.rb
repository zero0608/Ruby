class AddOrderIdToPurchaseItem < ActiveRecord::Migration[6.1]
  def change
    add_reference :purchase_items, :order, foreign_key: true
  end
end
