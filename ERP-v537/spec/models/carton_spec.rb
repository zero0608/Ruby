require 'rails_helper'

RSpec.describe Carton, type: :model do
  describe 'Carton association' do
  	it 'belongs_to product' do
  		assc = described_class.reflect_on_association(:product)
      expect(assc.macro).to eq :belongs_to
    end 
  end 
end
