class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.references :deal, null: true, foreign_key: true
      t.string :note

      t.timestamps
    end
  end
end
