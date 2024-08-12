class AddContainerCostToPurchaseItem < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_items, :container_cost, :float
  end
end
