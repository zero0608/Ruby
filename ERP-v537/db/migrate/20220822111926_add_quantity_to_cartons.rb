class AddQuantityToCartons < ActiveRecord::Migration[6.1]
  def change
    add_column :cartons, :quantity, :integer
  end
end
