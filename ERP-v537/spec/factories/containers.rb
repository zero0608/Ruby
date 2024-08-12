FactoryBot.define do
  factory :container do
    supplier { nil }
    container_number { 1 }
    shipping_date { "2021-08-11" }
    port_eta { "MyString" }
    arriving_to_dc { "MyString" }
    status { 1 }
  end
end
