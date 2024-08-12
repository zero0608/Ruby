class CreateContainerPostings < ActiveRecord::Migration[6.1]
  def change
    create_table :container_postings do |t|
      t.references :container, null: false, foreign_key: true

      t.timestamps
    end
  end
end
