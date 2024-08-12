class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.references :deal, null: true, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.string :invoice_number
      t.date :invoice_date
      t.date :payment_due
      t.integer :status
      t.string :notes
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.string :billing_address
      t.string :billing_city
      t.string :billing_zip
      t.string :billing_country
      t.string :billing_state
      t.string :shipping_address
      t.string :shipping_city
      t.string :shipping_zip
      t.string :shipping_country
      t.string :shipping_state
      t.string :discount
      t.float :discount_amount
      t.string :tax
      t.float :tax_amount
      t.string :shipping_method

      t.timestamps
    end
  end
end
