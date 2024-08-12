class AddNameToReplacementReferences < ActiveRecord::Migration[6.1]
  def change
    add_column :replacement_references, :name, :string
  end
end
