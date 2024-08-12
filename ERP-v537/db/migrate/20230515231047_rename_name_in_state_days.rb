class RenameNameInStateDays < ActiveRecord::Migration[6.1]
  def change
    rename_column :state_days, :full_name, :region
  end
end
