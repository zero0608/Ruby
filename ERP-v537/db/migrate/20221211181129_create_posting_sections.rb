class CreatePostingSections < ActiveRecord::Migration[6.1]
  def change
    create_table :posting_sections do |t|
      t.references :order, null: false, foreign_key: true
      t.string :dispute_pay_reason
      t.string :dispute_not_paid_reason
      t.string :amount
      t.string :store

      t.timestamps
    end
  end
end
