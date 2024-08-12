class AddApproveDateToExpenses < ActiveRecord::Migration[6.1]
  def change
    add_column :expenses, :tax, :float
    add_reference :expenses, :approver, foreign_key: { to_table: :employees }
    add_column :expenses, :approve_date, :date
  end
end
