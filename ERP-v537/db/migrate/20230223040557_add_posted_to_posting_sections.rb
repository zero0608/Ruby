class AddPostedToPostingSections < ActiveRecord::Migration[6.1]
  def change
    add_column :posting_sections, :posted, :boolean
  end
end
