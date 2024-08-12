class AddCategoryIdToProductVariants < ActiveRecord::Migration[6.1]
  def change
    add_reference :product_variants, :category, foreign_key: true
  end
end
