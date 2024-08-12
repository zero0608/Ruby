class AddStoreToSalesContact < ActiveRecord::Migration[6.1]
  def change
    add_column :sales_contacts, :store, :string
  end
end
