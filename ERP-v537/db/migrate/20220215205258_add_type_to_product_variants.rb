class AddTypeToProductVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :type, :string
  end
end
