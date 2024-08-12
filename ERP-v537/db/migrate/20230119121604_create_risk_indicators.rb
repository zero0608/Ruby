class CreateRiskIndicators < ActiveRecord::Migration[6.1]
  def change
    create_table :risk_indicators do |t|
      t.string :risk_type
      t.integer :assigned_status

      t.timestamps
    end
  end
end
