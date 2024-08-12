class AddIndicatorToShippings < ActiveRecord::Migration[6.1]
  def change
    add_column :approval_sections, :responded, :integer 
    add_column :review_sections, :responded, :integer 
    add_column :posting_sections, :responded, :integer 
    add_column :record_sections, :responded, :integer 
  end
end
