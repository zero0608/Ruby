class AddReceivedToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :received_quantity, :integer
    add_column :product_variants, :to_do_quantity, :integer
  end
end
