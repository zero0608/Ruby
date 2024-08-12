class AddPriceToInvoiceLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :invoice_line_items, :price, :float
  end
end
