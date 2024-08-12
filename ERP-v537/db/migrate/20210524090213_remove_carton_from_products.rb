class RemoveCartonFromProducts < ActiveRecord::Migration[6.1]
  def change
    remove_column :products, :carton, :json
  end
end
