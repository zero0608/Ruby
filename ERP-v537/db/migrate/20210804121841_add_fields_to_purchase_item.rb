class AddFieldsToPurchaseItem < ActiveRecord::Migration[6.1]
  def change
    add_reference :purchase_items, :product, foreign_key: true
    add_reference :purchase_items, :product_variant, foreign_key: true
    add_column :purchase_items, :purchase_type, :string
  end
end
