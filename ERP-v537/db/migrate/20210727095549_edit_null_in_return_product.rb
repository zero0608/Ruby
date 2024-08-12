class EditNullInReturnProduct < ActiveRecord::Migration[6.1]
  def change
    change_column :return_products, :issue_id, :bigint, null: true
  end
end
