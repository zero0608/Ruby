class AddTaxToShippingDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :tax, :string
  end
end
