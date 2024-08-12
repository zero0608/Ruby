class UpdateExpensePostings < ActiveRecord::Migration[6.1]
  def change
    drop_table :expense_records
    remove_column :expense_postings, :invoice_amount
    remove_column :expense_postings, :approved_ammount
    remove_column :expense_postings, :responded
    add_column :expense_postings, :status, :integer, :default => 0
  end
end
