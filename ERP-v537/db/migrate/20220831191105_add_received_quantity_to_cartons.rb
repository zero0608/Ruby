class AddReceivedQuantityToCartons < ActiveRecord::Migration[6.1]
  def change
    add_column :cartons, :received_quantity, :integer
    add_column :cartons, :to_do_quantity, :integer
  end
end
