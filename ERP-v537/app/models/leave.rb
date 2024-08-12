class Leave < ApplicationRecord
  belongs_to :employee

  enum type: [:PTO, :Personal, :Sick, :Unpaid]

  def start_time
    self.start_date
  end

  def end_time
    self.end_date
  end
end