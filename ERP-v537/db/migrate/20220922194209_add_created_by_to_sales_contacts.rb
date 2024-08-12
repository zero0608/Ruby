class AddCreatedByToSalesContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :sales_contacts, :created_by, :integer
  end
end
