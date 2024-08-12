class AddVariantIdToReturnProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :return_products, :store, :string
    add_reference :return_products, :product_variant, foreign_key: true
  end
end