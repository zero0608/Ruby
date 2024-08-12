class AddStockToProductVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :stock, :string
  end
end
