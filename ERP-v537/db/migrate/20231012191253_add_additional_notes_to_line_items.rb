class AddAdditionalNotesToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :invoice_line_items, :additional_notes, :string
    add_column :line_items, :additional_notes, :string
    add_column :customer_shipping_addresses, :first_name, :string
    add_column :customer_shipping_addresses, :last_name, :string
    add_column :customer_shipping_addresses, :phone, :string
    add_column :customer_shipping_addresses, :email, :string
    add_column :invoice_line_items, :return_id, :integer
  end
end