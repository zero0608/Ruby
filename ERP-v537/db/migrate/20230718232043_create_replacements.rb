class CreateReplacements < ActiveRecord::Migration[6.1]
  def change
    add_column :user_groups, :replacement_view, :boolean
    add_column :user_groups, :replacement_cru, :boolean

    create_table :replacements do |t|
      t.references :product_part, foreign_key: true
      t.string :description
      t.timestamps
    end
    
    create_table :replacement_references do |t|
      t.references :replacement, foreign_key: true
      t.references :product_variant, foreign_key: true
    end
  end
end
