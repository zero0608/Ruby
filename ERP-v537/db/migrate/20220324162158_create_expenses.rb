class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.references :employee, foreign_key: true
      t.string :category
      t.date :expense_date
      t.float :amount
      t.string :status

      t.timestamps
    end
  end
end
