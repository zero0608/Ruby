class AddColumnsToExpenses < ActiveRecord::Migration[6.1]
  def change
    add_reference :expenses, :expense_type, null: true, foreign_key: true
    add_reference :expenses, :expense_category, null: true, foreign_key: true
    add_reference :expenses, :expense_subcategory, null: true, foreign_key: true
    add_reference :expenses, :expense_payment_method, null: true, foreign_key: true
    add_column :expenses, :store, :string
    add_column :expenses, :gst, :string
    add_column :expenses, :pst, :string
  end
end
