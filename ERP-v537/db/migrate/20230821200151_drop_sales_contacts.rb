class DropSalesContacts < ActiveRecord::Migration[6.1]
  def change
    remove_column :deals, :sales_contact_id, :integer
    
    drop_table :sales_order_histories do |t|
      t.integer :deal_id
      t.integer :sales_contact_id
      t.integer :order_id
      t.string :note

      t.timestamps
    end

    drop_table :sales_contacts do |t|
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
      t.integer :created_by
      t.string :lead_source
      t.string :notes_title
      t.string :notes_title
      t.date :last_contact_date
      t.integer :risk_indicator_id
      t.string :risk_reason
      t.string :store

      t.timestamps
    end
  end
end
