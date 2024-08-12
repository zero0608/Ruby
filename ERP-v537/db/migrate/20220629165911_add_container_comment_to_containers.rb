class AddContainerCommentToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :containers, :container_comment, :string
  end
end
