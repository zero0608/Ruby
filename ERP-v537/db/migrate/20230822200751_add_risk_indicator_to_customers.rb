class AddRiskIndicatorToCustomers < ActiveRecord::Migration[6.1]
  def change
    add_reference :customers, :risk_indicator, foreign_key: true
    add_column :customers, :risk_reason, :string

    add_column :customers, :trade_name, :string
    add_column :customers, :trade_number, :string

    add_reference :deals, :customer, foreign_key: true

    add_reference :customers, :employee, foreign_key: true
    add_reference :deals, :employee, foreign_key: true
    add_reference :orders, :employee, foreign_key: true

    remove_column :deals, :deal_owner, :integer

    remove_column :invoices, :payment_due, :date
    add_reference :invoices, :employee, foreign_key: true

    remove_column :invoices, :contact_name, :string
    remove_column :invoices, :contact_email, :string
    remove_column :invoices, :contact_phone, :string
    remove_column :invoices, :billing_address, :string
    remove_column :invoices, :billing_city, :string
    remove_column :invoices, :billing_zip, :string
    remove_column :invoices, :billing_country, :string
    remove_column :invoices, :billing_state, :string
    remove_column :invoices, :shipping_address, :string
    remove_column :invoices, :shipping_city, :string
    remove_column :invoices, :shipping_zip, :string
    remove_column :invoices, :shipping_country, :string
    remove_column :invoices, :shipping_state, :string
    remove_column :invoices, :same_as_billing, :boolean

    create_table :customer_billing_addresses do |t|
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :zip
      t.references :customer, foreign_key: true

      t.timestamps
    end

    create_table :customer_shipping_addresses do |t|
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :zip
      t.references :customer, foreign_key: true

      t.timestamps
    end

    add_reference :invoices, :customer_billing_address, foreign_key: true
    add_reference :invoices, :customer_shipping_address, foreign_key: true
    add_column :invoices, :shipping_type, :string
  end
end
