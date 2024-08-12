class RemoveAddressIdFromInvoices < ActiveRecord::Migration[6.1]
  def change
    remove_reference :invoices, :customer_billing_address, foreign_key: true
    remove_reference :invoices, :customer_shipping_address, foreign_key: true
    add_column :invoices, :order_name, :string
  end
end
