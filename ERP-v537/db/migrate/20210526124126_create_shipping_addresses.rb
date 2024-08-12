class CreateShippingAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :shipping_addresses do |t|
      t.references :order, null: false, foreign_key: true
      t.string :address1
      t.string :address2
      t.string :city
      t.string :country
      t.string :company
      t.string :country_code
      t.string :first_name
      t.string :last_name
      t.string :latitude
      t.string :longitude
      t.string :name
      t.string :phone
      t.string :province
      t.string :province_code
      t.string :zip

      t.timestamps
    end
  end
end
