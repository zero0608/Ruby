class AddM2ParentSkuToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :m2_product_sku, :string
  end
end
