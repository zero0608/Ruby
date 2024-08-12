class IssueDetail < ApplicationRecord
  belongs_to :issue, optional: true
  
  enum shipping_charges: [ :replaced_shipping, :redirect_shipping, :shipping_disposal, :storage_charges, :return_shipping_charges, :surcharge, :detention_fee, :attempted_delivery ]
  enum resolution_type: [ "Full Replacement", "Full Refund", "Partial Refund", "Replacement Part", "Repackaging", "Exchange", "Amazon/Home Depot", "Chargeback", "Return Shipping", "Disposal Fee", "Furniture Repair", "Other" ]
end