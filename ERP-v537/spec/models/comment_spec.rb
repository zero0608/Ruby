require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'Comment association' do
   it 'belongs_to user' do
    assc = described_class.reflect_on_association(:user)
    expect(assc.macro).to eq :belongs_to
   end    
  end 
end
