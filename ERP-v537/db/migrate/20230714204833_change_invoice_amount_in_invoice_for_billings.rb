class ChangeInvoiceAmountInInvoiceForBillings < ActiveRecord::Migration[6.1]
  def change
    change_column :invoice_for_billings, :invoice_amount, "float USING CAST(invoice_amount AS float)"
    change_column :invoice_for_wgds, :invoice_amount, "float USING CAST(invoice_amount AS float)"
  end
end
