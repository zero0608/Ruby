class AddStatusToShippingDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :status, :integer
  end
end
