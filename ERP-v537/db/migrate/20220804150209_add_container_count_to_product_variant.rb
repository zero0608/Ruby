class AddContainerCountToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :container_count, :string
  end
end
