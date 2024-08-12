class AddShippingClaimTypeToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :shipping_claim_type, :integer
  end
end
