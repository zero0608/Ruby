class AddSkuAndQuantityToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :sku, :string
    add_column :products, :quantity, :integer
  end
end
