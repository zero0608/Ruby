class CreateMergePackingSlip < ActiveRecord::Migration[6.1]
  def change
    create_table :merge_packing_slips do |t|
      t.integer :index
      t.string :store
      t.integer :order_id, array: true

      t.timestamps
    end
  end
end
