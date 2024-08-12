class CreateAccountingExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :accounting_expenses do |t|
      t.references:expense_type, null: true, foreign_key: true
      t.references:expense_category, null: true, foreign_key: true
      t.references:expense_subcategory, null: true, foreign_key: true
      t.references:expense_payment_method, null: true, foreign_key: true
      t.string :gst
      t.string :pst
      t.string :store

      t.timestamps
    end
  end
end
