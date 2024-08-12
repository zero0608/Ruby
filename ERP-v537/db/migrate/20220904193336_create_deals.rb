class CreateDeals < ActiveRecord::Migration[6.1]
  def change
    create_table :deals do |t|
      t.references :sales_contact, null: true, foreign_key: true
      t.string :description
      t.integer :stage
      t.string :lead_value
      t.integer :source
      t.string :deal_name
      t.date :closing_date
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
      t.string :secondary_phone
      t.string :trade_name


      t.timestamps
    end
  end
end
