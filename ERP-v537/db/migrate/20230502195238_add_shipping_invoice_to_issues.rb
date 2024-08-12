class AddShippingInvoiceToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :shipping_invoice, :string
    rename_column :issues, :product_claims, :dispute_type
  end
end
