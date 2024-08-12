class AddSstatusToPostingSections < ActiveRecord::Migration[6.1]
  def change
    add_column :posting_sections, :status, :integer
  end
end
