class AddVarSkuToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :var_sku, :string
  end
end
