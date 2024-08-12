class AddOldShopifyIdToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :old_shopify_product_id, :string
  end
end
