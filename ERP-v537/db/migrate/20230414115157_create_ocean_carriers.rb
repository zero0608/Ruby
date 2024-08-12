class CreateOceanCarriers < ActiveRecord::Migration[6.1]
  def change
    create_table :ocean_carriers do |t|
      t.string :name
      t.string :store

      t.timestamps
    end
  end
end
