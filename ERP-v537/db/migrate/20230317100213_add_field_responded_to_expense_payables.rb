class AddFieldRespondedToExpensePayables < ActiveRecord::Migration[6.1]
  def change
    add_column :expense_postings, :responded, :integer 
    add_column :expense_records, :responded, :integer 
  end
end
