class CreateTruckBrokers < ActiveRecord::Migration[6.1]
  def change
    create_table :truck_brokers do |t|
      t.string :name
      t.string :country

      t.timestamps
    end

    add_reference :carriers, :truck_broker, foreign_key: true
    add_reference :shipping_quotes, :truck_broker, foreign_key: true
  end
end
