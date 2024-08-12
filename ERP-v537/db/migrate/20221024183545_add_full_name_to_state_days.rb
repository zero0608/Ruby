class AddFullNameToStateDays < ActiveRecord::Migration[6.1]
  def change
    add_column :state_days, :full_name, :string
  end
end
