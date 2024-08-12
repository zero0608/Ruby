class AddStoreToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :store, :string
  end
end
