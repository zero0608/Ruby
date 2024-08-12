class AddUpgradeToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :upgrade, :integer, default: '0'
  end
end
