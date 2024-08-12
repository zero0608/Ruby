class CreateCommissionRate < ActiveRecord::Migration[6.1]
  def change
    create_table :commission_rates do |t|
      t.references :employee, foreign_key: true
      t.float :lower_range
      t.float :upper_range
      t.float :rate

      t.timestamps
    end

    remove_column :employees, :commission_rate, :float
    add_column :employees, :sales_permission, :boolean, default: false
  end
end