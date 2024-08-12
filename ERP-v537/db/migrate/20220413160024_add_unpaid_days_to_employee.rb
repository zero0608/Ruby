class AddUnpaidDaysToEmployee < ActiveRecord::Migration[6.1]
  def change
    add_column :employees, :unpaid_days, :integer
    add_column :employees, :pto_remain, :integer
    add_column :employees, :personal_remain, :integer
    add_column :employees, :sick_remain, :integer
    add_column :employees, :unpaid_remain, :integer
  end
end
