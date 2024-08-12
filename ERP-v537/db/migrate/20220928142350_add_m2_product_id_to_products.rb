class AddM2ProductIdToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :m2_product_id, :integer
    add_column :product_variants, :m2_product_id, :integer
  end
end
