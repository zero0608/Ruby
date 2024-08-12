class AddPostingToExpensePostings < ActiveRecord::Migration[6.1]
  def change
    add_column :expense_postings, :posting, :boolean, default: "false"
    add_column :expense_records, :posting, :boolean, default: "false"
  end
end
