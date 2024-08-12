class AddMtoToInvoiceLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :invoice_line_items, :mto, :boolean, default: false
  end
end
