class AddChargeBackToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :chargeback_id, :string
    add_column :issues, :chargeback_reason, :string
    add_column :issues, :win_likelihood, :string
    add_column :issues, :chargeback_dispute, :boolean
    add_column :issues, :outcome_notes, :string
  end
end
