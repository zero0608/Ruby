class CreateLocalCities < ActiveRecord::Migration[6.1]
  def change
    create_table :local_cities do |t|
      t.string :city
      t.string :store

      t.timestamps
    end
  end
end
