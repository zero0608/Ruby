class AddSubcategoryIdToProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :subcategory, foreign_key: true
    add_reference :product_variants, :subcategory, foreign_key: true


  end
end
