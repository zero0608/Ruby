class AddKindOfOrderToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :kind_of_order, :string
  end
end
