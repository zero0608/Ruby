class AddMethodToTransfer < ActiveRecord::Migration[6.1]
  def change
    add_column :transfer_tables, :store, :string
    add_column :transfer_tables, :delivery_method, :string
  end
end
