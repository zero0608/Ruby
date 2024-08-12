class AddOceanCarrierToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :containers, :ocean_carrier, :string
  end
end
