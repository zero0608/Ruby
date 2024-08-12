class AddAdditionalChargesToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :additional_charges, :json
    add_column :shipping_details, :additional_fees, :json
  end
end
