class AddOceanCarrierIdToContainer < ActiveRecord::Migration[6.1]
  def change
    add_reference :containers, :ocean_carrier, null: true, foreign_key: true
  end
end
