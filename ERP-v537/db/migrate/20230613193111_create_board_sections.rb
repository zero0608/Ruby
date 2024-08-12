class CreateBoardSections < ActiveRecord::Migration[6.1]
  def change
    create_table :board_sections do |t|
      t.string :name

      t.timestamps
    end

    create_table :board_pages do |t|
      t.string :name
      t.string :content
      t.boolean :main_page
      t.string :tag, array: true, default: []
      t.references :board_section, foreign_key: true

      t.timestamps
    end
    
    add_column :user_groups, :board_view, :boolean
    add_column :user_groups, :board_cru, :boolean
  end
end
