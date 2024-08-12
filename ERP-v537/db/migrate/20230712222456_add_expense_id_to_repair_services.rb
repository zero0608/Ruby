class AddExpenseIdToRepairServices < ActiveRecord::Migration[6.1]
  def change
    add_column :repair_services, :expense_id, :integer
  end
end
