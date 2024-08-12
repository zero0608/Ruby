class AddNotesToSalesContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :sales_contacts, :lead_source, :string
    add_column :sales_contacts, :notes_title, :string
    add_column :sales_contacts, :notes, :string
  end
end
