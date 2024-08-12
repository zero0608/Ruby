class AddTagUserId < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :tag_user_id, :string
  end
end
