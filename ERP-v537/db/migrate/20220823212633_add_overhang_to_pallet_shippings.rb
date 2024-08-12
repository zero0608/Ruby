class AddOverhangToPalletShippings < ActiveRecord::Migration[6.1]
  def change
    add_column :pallet_shippings, :overhang, :boolean
  end
end
