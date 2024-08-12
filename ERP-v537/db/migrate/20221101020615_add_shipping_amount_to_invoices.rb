class AddShippingAmountToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :same_as_billing, :boolean
    remove_column :invoices, :tax, :string
  end
end
