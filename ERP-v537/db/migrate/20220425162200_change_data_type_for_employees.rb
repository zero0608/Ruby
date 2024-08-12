class ChangeDataTypeForEmployees < ActiveRecord::Migration[6.1]
  def change
    change_column :employees, :pto_days, :float
    change_column :employees, :pto_remain, :float
    change_column :employees, :personal_days, :float
    change_column :employees, :personal_remain, :float
    change_column :employees, :sick_days, :float
    change_column :employees, :sick_remain, :float
    change_column :employees, :unpaid_days, :float
  end
end
