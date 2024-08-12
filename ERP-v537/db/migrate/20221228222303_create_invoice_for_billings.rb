class CreateInvoiceForBillings < ActiveRecord::Migration[6.1]
  def change
    create_table :invoice_for_billings do |t|
      t.references :order, null: true, foreign_key: true
      t.string :invoice_number
      t.string :invoice_amount
      t.date :invoice_date
      t.date :invoice_due_date
      t.string :invoice_difference
      
      t.timestamps
    end
  end
end
