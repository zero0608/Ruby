require 'rails_helper'

RSpec.describe ShippingDetail, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'ShippingDetail association' do
   it 'belongs_to order' do
    assc = described_class.reflect_on_association(:order)
    expect(assc.macro).to eq :belongs_to
   end
   it 'belongs_to carrier' do
    assc = described_class.reflect_on_association(:carrier)
    expect(assc.macro).to eq :belongs_to
   end
   it 'has_many line_items' do
    assc = described_class.reflect_on_association(:line_items)
    expect(assc.macro).to eq :has_many
   end
   it 'has_many pallet_shippings' do
    assc = described_class.reflect_on_association(:pallet_shippings)
    expect(assc.macro).to eq :has_many
   end
  end
end
