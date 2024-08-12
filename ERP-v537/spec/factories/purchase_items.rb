FactoryBot.define do
  factory :purchase_item do
    line_item { nil }
    purchase { nil }
    quantity { 1 }
  end
end
