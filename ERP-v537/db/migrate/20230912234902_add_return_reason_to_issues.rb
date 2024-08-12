class AddReturnReasonToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :return_reason, :integer
  end
end
