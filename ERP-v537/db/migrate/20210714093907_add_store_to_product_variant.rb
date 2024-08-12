class AddStoreToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :store, :string
  end
end
