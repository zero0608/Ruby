class AddSupplierIdToIssue < ActiveRecord::Migration[6.1]
  def change
    add_reference :issues, :supplier, foreign_key: true
  end
end
