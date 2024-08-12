class CreateExpenseCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_categories do |t|
      t.references:expense_type, null: true, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
