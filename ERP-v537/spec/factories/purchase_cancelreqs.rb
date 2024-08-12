FactoryBot.define do
  factory :purchase_cancelreq do
    purchase { nil }
    purchase_item { nil }
    cancel_quantity { 1 }
  end
end
