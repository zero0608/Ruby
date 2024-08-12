class CreateContainers < ActiveRecord::Migration[6.1]
  def change
    create_table :containers do |t|
      t.references :supplier, null: true, foreign_key: true
      t.integer :container_number
      t.date :shipping_date
      t.date :port_eta
      t.date :arriving_to_dc
      t.integer :status

      t.timestamps
    end
  end
end
