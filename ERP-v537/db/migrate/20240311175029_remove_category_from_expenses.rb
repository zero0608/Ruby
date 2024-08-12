class RemoveCategoryFromExpenses < ActiveRecord::Migration[6.1]
  def change
    remove_column :expenses, :category, :string
  end
end
