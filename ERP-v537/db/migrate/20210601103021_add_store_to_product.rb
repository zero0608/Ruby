class AddStoreToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :store, :string
  end
end
