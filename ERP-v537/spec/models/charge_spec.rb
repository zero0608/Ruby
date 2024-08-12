require 'rails_helper'

RSpec.describe Charge, type: :model do
  describe 'Charge association' do 
  	it 'belongs_to receipt' do
  		assc = described_class.reflect_on_association(:receipt)
      expect(assc.macro).to eq :belongs_to
  	end
  end 
end
