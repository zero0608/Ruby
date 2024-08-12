class AddLastContactDateToSalesContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :sales_contacts, :last_contact_date, :date
  end
end
