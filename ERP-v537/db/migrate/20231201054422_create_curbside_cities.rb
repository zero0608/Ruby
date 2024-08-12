class CreateCurbsideCities < ActiveRecord::Migration[6.1]
  def change
    create_table :curbside_cities do |t|
      t.references :tax_rate, foreign_key: true
      t.string :city
      t.string :city_type

      t.timestamps
    end
  end
end
