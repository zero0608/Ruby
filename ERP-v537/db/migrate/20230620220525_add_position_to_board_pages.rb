class AddPositionToBoardPages < ActiveRecord::Migration[6.1]
  def change
    add_column :board_pages, :position, :integer
    add_column :board_sections, :position, :integer
    remove_column :board_pages, :main_page, :boolean
  end
end
