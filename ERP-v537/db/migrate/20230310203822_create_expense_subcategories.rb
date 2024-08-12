class CreateExpenseSubcategories < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_subcategories do |t|
      t.references:expense_category, null: true, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
