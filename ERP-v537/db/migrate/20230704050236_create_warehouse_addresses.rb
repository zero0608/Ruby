class CreateWarehouseAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :warehouse_addresses do |t|
      t.references :warehouse, null: false, foreign_key: true
      t.string :address1
      t.string :address2
      t.string :city
      t.string :country
      t.string :country_code
      t.string :latitude
      t.string :longitude
      t.string :name
      t.string :phone
      t.string :province
      t.string :zip
      t.string :email

      t.timestamps
    end
  end
end
