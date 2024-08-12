require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'UserGroup association' do
   it 'has_many users' do
    assc = described_class.reflect_on_association(:users)
    expect(assc.macro).to eq :has_many
   end
  end
end
