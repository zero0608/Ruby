class AddOversizedColumnToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :oversized, :boolean
    add_column :product_variants, :oversized, :boolean
  end
end
