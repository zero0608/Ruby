class AddUniqueIdInTable < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :uni_order_id, :string
    add_column :product_variants, :uni_variant_id, :string
    add_column :products, :uni_product_id, :string
    add_column :line_items, :uni_line_item_id, :string
  end
end
