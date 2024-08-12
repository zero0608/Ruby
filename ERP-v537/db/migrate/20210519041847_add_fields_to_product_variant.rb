class AddFieldsToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :fabric_use, :string
    add_column :product_variants, :unit_cost, :string
  end
end
