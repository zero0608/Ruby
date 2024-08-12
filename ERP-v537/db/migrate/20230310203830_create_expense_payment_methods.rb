class CreateExpensePaymentMethods < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_payment_methods do |t|
      t.references:expense_subcategory, null: true, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
