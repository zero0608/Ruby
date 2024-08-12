class CreateContainerCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :container_costs do |t|
      t.references :container, null: false, foreign_key: true
      t.string :carrier_type
      t.string :name
      t.float :amount

      t.timestamps
    end
  end
end
