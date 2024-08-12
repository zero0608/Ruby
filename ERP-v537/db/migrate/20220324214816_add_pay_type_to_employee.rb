class AddPayTypeToEmployee < ActiveRecord::Migration[6.1]
  def change
    add_column :employees, :pay_type, :string
  end
end
