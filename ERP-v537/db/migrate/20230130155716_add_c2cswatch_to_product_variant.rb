class AddC2cswatchToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :c2c_swatch, :string
  end
end
