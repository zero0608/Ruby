class AddOrderLinkToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :order_link, :string
    add_column :issues, :bill_of_lading, :string
    add_column :issues, :claims_submission_date, :date
    add_column :issues, :claims_reference, :string
    add_column :issues, :pickup_date, :date
    add_column :issues, :last_scanned_date, :date
    add_column :issues, :assign_product, :json, default: {}
  end
end