class CreateExpenseRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_records do |t|
      t.references :expense, null: true, foreign_key: true
      t.string :invoice_amount
      t.string :approved_ammount
      t.string :reason
      t.string :store

      t.timestamps
    end
  end
end
