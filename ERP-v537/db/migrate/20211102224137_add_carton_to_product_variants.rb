class AddCartonToProductVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :carton, :integer
    add_column :product_variants, :height, :integer
    add_column :product_variants, :width, :integer
    add_column :product_variants, :length, :integer
  end
end
