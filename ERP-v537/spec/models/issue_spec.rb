require 'rails_helper'

RSpec.describe Issue, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'Issue association' do
   it 'belongs_to issue' do
      assc = described_class.reflect_on_association(:order)
      expect(assc.macro).to eq :belongs_to
   end 

   it 'belongs_to user' do
    assc = described_class.reflect_on_association(:user)
    expect(assc.macro).to eq :belongs_to
   end

   it 'belongs_to comments' do
    assc = described_class.reflect_on_association(:comments)
    expect(assc.macro).to eq :has_many
   end  

  end
end
