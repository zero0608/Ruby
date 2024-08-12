class AddRestockingChangedToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :restocking_changed, :boolean, default: "false"
  end
end
