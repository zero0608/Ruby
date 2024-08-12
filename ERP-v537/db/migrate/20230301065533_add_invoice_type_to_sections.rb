class AddInvoiceTypeToSections < ActiveRecord::Migration[6.1]
  def change
    add_column :record_sections, :invoice_type, :string
    add_column :approval_sections, :invoice_type, :string
    add_column :posting_sections, :invoice_type, :string
    add_column :review_sections, :invoice_type, :string    
  end
end
