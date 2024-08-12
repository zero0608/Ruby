class AddFactoryToProductVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :factory, :string
  end
end
