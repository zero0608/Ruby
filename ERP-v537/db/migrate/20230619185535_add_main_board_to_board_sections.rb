class AddMainBoardToBoardSections < ActiveRecord::Migration[6.1]
  def change
    add_column :board_sections, :main_board, :integer
  end
end
