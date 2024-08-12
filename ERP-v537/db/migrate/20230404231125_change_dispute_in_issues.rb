class ChangeDisputeInIssues < ActiveRecord::Migration[6.1]
  def change
    change_column :issues, :claims_dispute, :integer, :using => "case when claims_dispute is null then null when claims_dispute then 1 else 0 end"
    change_column :issues, :chargeback_dispute, :integer, :using => "case when chargeback_dispute is null then null when chargeback_dispute then 1 else 0 end"
  end
end
