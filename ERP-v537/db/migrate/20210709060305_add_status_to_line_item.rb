class AddStatusToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :status, :integer
  end
end
