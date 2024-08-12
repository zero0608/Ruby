class ChangeColumnToProductLocation < ActiveRecord::Migration[6.1]
  def change
    change_column :product_locations, :product_variant_id, :bigint, null: true
  end
end
