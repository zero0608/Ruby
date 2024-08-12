class RiskIndicator < ApplicationRecord
  has_many :customers, dependent: :nullify

  enum assigned_status: { new_order: 0, in_progress: 1, cancel_confirmed: 2, delayed: 3, hold_confirmed: 4, completed: 5, cancel_request: 6, rejected: 7, hold_request: 8, pending_payment: 9 }
end
