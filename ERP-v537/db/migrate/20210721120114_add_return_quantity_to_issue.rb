class AddReturnQuantityToIssue < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :return_quantity, :integer
  end
end
