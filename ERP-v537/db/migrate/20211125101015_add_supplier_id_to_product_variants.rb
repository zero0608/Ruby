class AddSupplierIdToProductVariants < ActiveRecord::Migration[6.1]
  def change
    add_reference :product_variants, :supplier, null: true, foreign_key: true
  end
end
