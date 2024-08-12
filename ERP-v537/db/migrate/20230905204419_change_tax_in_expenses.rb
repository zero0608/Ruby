class ChangeTaxInExpenses < ActiveRecord::Migration[6.1]
  def self.up
    change_column :expenses, :gst, :float, :using => "case when gst is null then null when gst = '' then null else CAST(gst AS float) end"
    change_column :expenses, :pst, :float, :using => "case when pst is null then null when pst = '' then null else CAST(pst AS float) end"
  end

  def self.down
    change_column :expenses, :gst, :string, :using => "case when gst is null then null else CAST(gst AS character varying) end"
    change_column :expenses, :pst, :string, :using => "case when pst is null then null else CAST(pst AS character varying) end"
  end
end
