class AddStoreToProductLOcation < ActiveRecord::Migration[6.1]
  def change
    add_column :product_locations, :store, :string
  end
end
