class AddCommissionRateToEmployees < ActiveRecord::Migration[6.1]
  def change
    add_column :employees, :commission_rate, :float
  end
end
