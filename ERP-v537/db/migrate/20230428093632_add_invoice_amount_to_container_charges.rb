class AddInvoiceAmountToContainerCharges < ActiveRecord::Migration[6.1]
  def change
    add_column :container_charges, :invoice_number, :string
  end
end
