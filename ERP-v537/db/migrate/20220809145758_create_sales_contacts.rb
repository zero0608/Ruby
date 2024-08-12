class CreateSalesContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :sales_contacts do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :sales_revenue
      t.string :street
      t.string :city
      t.string :state
      t.string :country
      t.string :zip_code
      t.string :trade
      t.boolean :designer

      t.timestamps
    end
  end
end
