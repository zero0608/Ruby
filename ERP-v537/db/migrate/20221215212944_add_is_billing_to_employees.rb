class AddIsBillingToEmployees < ActiveRecord::Migration[6.1]
  def change
    add_column :employees, :is_billing, :boolean, default: "false"
  end
end
