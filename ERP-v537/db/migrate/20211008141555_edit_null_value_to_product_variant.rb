class EditNullValueToProductVariant < ActiveRecord::Migration[6.1]
  def change
    change_column :product_variants, :product_id, :bigint, null: true
  end
end
