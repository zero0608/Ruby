class AddTruckBrokerIdToReturns < ActiveRecord::Migration[6.1]
  def change
    add_column :returns, :truck_broker_id, :integer
  end
end
