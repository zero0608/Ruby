class CreateConsolidation < ActiveRecord::Migration[6.1]
  def change
    create_table :consolidations do |t|
      t.string :name
      t.string :store

      t.timestamps
    end

    remove_column :shipping_details, :consolidate_group, :integer
    add_reference :shipping_details, :consolidation, foreign_key: true
    add_reference :review_sections, :consolidation, foreign_key: true
    add_reference :posting_sections, :consolidation, foreign_key: true
    add_reference :record_sections, :consolidation, foreign_key: true
    add_reference :invoice_for_billings, :consolidation, foreign_key: true
    add_reference :invoice_for_wgds, :consolidation, foreign_key: true

    drop_table :approval_sections do |t|
      t.references :order
      t.string :reason
      t.string :amount
      t.string :store
      t.references :shipping_detail
      t.integer :responded
      t.string :invoice_type
      t.references :return
      t.timestamps
    end
  end
end
