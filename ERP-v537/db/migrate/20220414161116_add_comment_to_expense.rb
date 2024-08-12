class AddCommentToExpense < ActiveRecord::Migration[6.1]
  def change
    add_column :expenses, :comment, :string
  end
end
