class RemoveM2ProductSkuFromProducts < ActiveRecord::Migration[6.1]
  def change
    remove_column :products, :m2_product_sku, :string
  end
end
