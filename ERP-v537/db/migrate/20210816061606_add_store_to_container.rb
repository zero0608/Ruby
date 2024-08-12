class AddStoreToContainer < ActiveRecord::Migration[6.1]
  def change
    add_column :containers, :store, :string
  end
end
