describe Hostname, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:dns_record) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:hostname) }
    it { is_expected.to allow_value('google.com').for(:hostname) }
    it { is_expected.not_to allow_value('google_br.com').for(:hostname) }
  end
end
