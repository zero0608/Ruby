class AddPrintedToShippingDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :printed_bol, :boolean
    add_column :shipping_details, :printed_packing_slip, :boolean
  end
end
