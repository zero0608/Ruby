class AddFieldsToSalesContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :sales_contacts, :secondary_phone, :string
    add_column :sales_contacts, :trade_name, :string
  end
end
