class CreateInvoiceLineItems < ActiveRecord::Migration[6.1]
  def change
    create_table :invoice_line_items do |t|
      t.references :invoice, null: true, foreign_key: true
      t.references :product_variant, null: true, foreign_key: true
      t.integer :quantity
      t.timestamps
    end
  end
end
