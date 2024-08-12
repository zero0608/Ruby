class ChangeWhiteGloveInRecordSections < ActiveRecord::Migration[6.1]
  def change
    rename_column :record_sections, :White_glove, :white_glove
  end
end
