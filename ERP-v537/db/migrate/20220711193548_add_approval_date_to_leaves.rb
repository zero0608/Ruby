class AddApprovalDateToLeaves < ActiveRecord::Migration[6.1]
  def change
    add_column :leaves, :approval_date, :date
    add_column :leaves, :approved_by_id, :integer
  end
end