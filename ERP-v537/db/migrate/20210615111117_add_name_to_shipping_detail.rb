class AddNameToShippingDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :name, :string
  end
end
