class CreateInvoiceMacros < ActiveRecord::Migration[6.1]
  def change
    create_table :invoice_macros do |t|
      t.string :name
      t.string :description

      t.timestamps
    end

    add_reference :invoices, :invoice_macro, foreign_key: true
  end
end
