class Appointment < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :employee, optional: true
  belongs_to :showroom, optional: true
  
  enum appointment_type: { in_store: 0, virtual: 1, phone: 2 }

  def start_time
    self.appointment_date
  end
end