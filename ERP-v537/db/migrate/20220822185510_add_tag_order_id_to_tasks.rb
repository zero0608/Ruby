class AddTagOrderIdToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :tag_order_id, :string
  end
end
