require 'rails_helper'

RSpec.describe Order, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'Order association' do
   it 'belongs_to customer' do
      assc = described_class.reflect_on_association(:customer)
      expect(assc.macro).to eq :belongs_to
   end
   it 'has_one billing_address' do
      assc = described_class.reflect_on_association(:billing_address)
      expect(assc.macro).to eq :has_one
   end
   it 'has_one shipping_address' do
      assc = described_class.reflect_on_association(:shipping_address)
      expect(assc.macro).to eq :has_one
   end 	
   it 'has_many refunds' do
      assc = described_class.reflect_on_association(:refunds)
      expect(assc.macro).to eq :has_many
   end 	
   it 'has_many fulfillments' do
      assc = described_class.reflect_on_association(:fulfillments)
      expect(assc.macro).to eq :has_many
   end 	
   it 'has_many line_items' do
      assc = described_class.reflect_on_association(:line_items)
      expect(assc.macro).to eq :has_many
   end 	
   it 'has_many shipping_details' do
      assc = described_class.reflect_on_association(:shipping_details)
      expect(assc.macro).to eq :has_many
   end
   it 'has_many issues' do
      assc = described_class.reflect_on_association(:issues)
      expect(assc.macro).to eq :has_many
   end
   it 'has_many pallet_shippings' do
      assc = described_class.reflect_on_association(:pallet_shippings)
      expect(assc.macro).to eq :has_many
   end	    	   	
  end
end
