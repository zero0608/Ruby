class CreateExpensePaymentRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_payment_relations do |t|
      t.references :expense_subcategory, null: true, foreign_key: true
      t.references :expense_payment_method, null: true, foreign_key: true

      t.timestamps
    end

    remove_reference :expense_payment_methods, :expense_subcategory, foreign_key: true, null: true
  end
end
