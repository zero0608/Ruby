class AddTerminalToWarehouse < ActiveRecord::Migration[6.1]
  def change
    add_column :transfer_tables, :terminal, :string
  end
end
