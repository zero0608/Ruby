class AddDisputeToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :claims_dispute, :boolean
    add_column :issues, :dispute_amount, :float
    add_column :issues, :invoice_pay, :boolean
    add_column :issues, :product_claims, :string
  end
end
