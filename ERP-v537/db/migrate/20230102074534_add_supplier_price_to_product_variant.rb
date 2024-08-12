class AddSupplierPriceToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :supplier_price, :integer
  end
end
