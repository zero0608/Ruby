class AddStatusToIssue < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :status, :integer
  end
end