class AddFreightCarrierToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :containers, :freight_carrier, :string
  end
end
