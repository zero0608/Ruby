class AddPostedToRecordSections < ActiveRecord::Migration[6.1]
  def change
    add_column :record_sections, :posted, :boolean
    add_column :record_sections, :status, :integer
  end
end
