class AddFieldsToIssue < ActiveRecord::Migration[6.1]
  def change
    add_reference :issues, :line_item, foreign_key: true
    add_column :issues, :issue_type, :integer
    add_column :issues, :manufacturing_category, :integer
    add_column :issues, :shipping_category, :integer
    add_column :issues, :shipping_charges, :integer
    add_column :issues, :resolution_type, :integer
    add_column :issues, :shipping_amount, :string
    add_column :issues, :resolution_amount, :string
  end
end
