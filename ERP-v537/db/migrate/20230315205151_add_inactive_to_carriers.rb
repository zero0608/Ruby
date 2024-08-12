class AddInactiveToCarriers < ActiveRecord::Migration[6.1]
  def change
    add_column :carriers, :inactive, :boolean, default: "false"
  end
end
