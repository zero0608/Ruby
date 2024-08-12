class CreateApprovalSections < ActiveRecord::Migration[6.1]
  def change
    create_table :approval_sections do |t|
      t.references :order, null: false, foreign_key: true
      t.string :reason
      t.string :amount
      t.string :store

      t.timestamps
    end
  end
end
