class CreateIssueDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :issue_details do |t|
      t.references :issue, null: false, foreign_key: true
      t.string :main_type
      t.string :sub_type
      t.float :amount

      t.timestamps
    end
  end
end