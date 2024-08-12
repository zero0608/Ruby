class AddCancelAmountToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :cancel_quantity, :integer
  end
end
