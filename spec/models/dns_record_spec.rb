describe DnsRecord, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:hostnames).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:hostnames) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:ip) }
  end
end
