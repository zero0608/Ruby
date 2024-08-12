class AddConsolidateGroupToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :consolidate_group, :integer
  end
end
