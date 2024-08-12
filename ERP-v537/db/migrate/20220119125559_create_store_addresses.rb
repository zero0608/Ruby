class CreateStoreAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :store_addresses do |t|
      t.string :store
      t.text :full_address

      t.timestamps
    end
  end
end
