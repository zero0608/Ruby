class AddTagsToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :tags, :string
  end
end
