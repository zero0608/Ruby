class AddCarrierSerialNumberToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :containers, :carrier_serial_number, :string
  end
end
