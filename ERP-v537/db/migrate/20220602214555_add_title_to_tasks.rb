class AddTitleToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :title, :string
    add_column :tasks, :tag_user_id, :string
    remove_column :tasks, :assignee_id, :string
  end
end