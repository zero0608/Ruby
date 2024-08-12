class CreateMtoWarehouseTables < ActiveRecord::Migration[6.1]
  def change
    create_table :mto_warehouse_tables do |t|
      t.string :war_type
      t.integer :from_days
      t.integer :to_days

      t.timestamps
    end
  end
end
