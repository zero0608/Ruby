class AddStatusUpdateToProductVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :stock_update, :integer
  end
end
