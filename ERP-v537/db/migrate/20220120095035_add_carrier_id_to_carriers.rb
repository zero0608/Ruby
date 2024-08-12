class AddCarrierIdToCarriers < ActiveRecord::Migration[6.1]
  def change
    add_column :carriers, :carrierID, :string
  end
end
