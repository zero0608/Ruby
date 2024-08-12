class CreateCarrierContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :carrier_contacts do |t|
      t.references :carrier, null: false, foreign_key: true
      t.string :name
      t.string :number
      t.string :email
      
      t.timestamps
    end
  end
end
