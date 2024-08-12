require 'rails_helper'

RSpec.describe RefundLineItem, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'RefundLineItem association' do
   it 'belongs_to refund' do
    assc = described_class.reflect_on_association(:refund)
    expect(assc.macro).to eq :belongs_to
   end
   it 'belongs_to line_item' do
    assc = described_class.reflect_on_association(:line_item)
    expect(assc.macro).to eq :belongs_to
   end
  end 
end
