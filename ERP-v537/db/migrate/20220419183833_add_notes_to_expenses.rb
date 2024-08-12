class AddNotesToExpenses < ActiveRecord::Migration[6.1]
  def change
    add_column :expenses, :notes, :string
  end
end
