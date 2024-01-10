RSpec.describe DnsRecordsService do
  describe '#call' do
    context 'when there is a record with "dolor.com"' do
      it 'returns the expected result' do
        create(:dns_record, :dolor)
        dns_records_service = described_class.new({ included: 'dolor.com', page: 1 })
        result = dns_records_service.call

        expect(result[:total_records]).to eq(1)
        expect(result[:records].count).to eq(1)
        expect(result[:related_hostnames].count).to eq(1)
      end
    end

    context 'when there is a record with "amet.com"' do
      it 'returns the expected result' do
        create(:dns_record, :amet)
        dns_records_service = described_class.new({ included: 'amet.com', page: 1 })
        result = dns_records_service.call

        expect(result[:total_records]).to eq(1)
        expect(result[:records].count).to eq(1)
        expect(result[:related_hostnames].count).to eq(1)
      end
    end

    context 'when there are multiple records with different hostnames' do
      it 'returns the expected result with included and excluded hostnames' do
        dns_record1 = create(:dns_record)
        dns_record2 = create(:dns_record)
        dns_record3 = create(:dns_record)

        dns_record1.hostnames << create(:hostname, :dolor)
        dns_record1.hostnames << create(:hostname, :amet)
        dns_record2.hostnames << create(:hostname, :amet)
        dns_record3.hostnames << create(:hostname, :ipsum)

        dns_records_service = described_class.new({ included: 'dolor.com,amet.com', excluded: 'ipsum.com', page: 1 })
        result = dns_records_service.call

        expect(result[:total_records]).to eq(1)
        expect(result[:records].count).to eq(1)
        expect(result[:related_hostnames].count).to eq(2)

        expected_result = {
          total_records: 1,
          records: [{"id" => dns_record1.id, "ip" => dns_record1.ip }],
          related_hostnames: [
            { hostname: "dolor.com", count: 1 },
            { hostname: "amet.com", count: 1 }

          ]
        }

        expect(result).to eq(expected_result)
      end
    end

    context 'when there are multiple records with different hostnames' do
      it 'returns the expected result with excluded hostname' do
        dns_record1 = create(:dns_record)
        dns_record2 = create(:dns_record)
        dns_record3 = create(:dns_record)

        dns_record1.hostnames << create(:hostname, :dolor)
        dns_record1.hostnames << create(:hostname, :amet)
        dns_record2.hostnames << create(:hostname, :amet)
        dns_record3.hostnames << create(:hostname, :ipsum)

        dns_records_service = described_class.new({ excluded: 'ipsum.com', page: 1 })
        result = dns_records_service.call

        expect(result[:total_records]).to eq(2)
        expect(result[:records].count).to eq(2)
        expect(result[:related_hostnames].count).to eq(2)

        expected_result = {
          total_records: 2,
          records: [{ "id" => dns_record1.id, "ip" => dns_record1.ip }, { "id" => dns_record2.id, "ip" => dns_record2.ip }],
          related_hostnames: [
            { hostname: "dolor.com", count: 1 },
            { hostname: "amet.com", count: 2 }
          ]
        }

        expect(result).to eq(expected_result)
      end
    end

    context 'when there are multiple records with different hostnames' do
      it 'returns the expected result for all records without specific inclusion or exclusion' do
        dns_record1 = create(:dns_record)
        dns_record2 = create(:dns_record)
        dns_record3 = create(:dns_record)

        dns_record1.hostnames << create(:hostname, :dolor)
        dns_record1.hostnames << create(:hostname, :amet)
        dns_record2.hostnames << create(:hostname, :amet)
        dns_record3.hostnames << create(:hostname, :ipsum)

        dns_records_service = described_class.new({ page: 1 })
        result = dns_records_service.call

        expect(result[:total_records]).to eq(3)
        expect(result[:records].count).to eq(3)
        expect(result[:related_hostnames].count).to eq(3)

        expected_result = {
          total_records: 3,
          records: [{ "id" => dns_record1.id, "ip" => dns_record1.ip },
                    { "id" => dns_record2.id, "ip" => dns_record2.ip },
                    { "id" => dns_record3.id, "ip" => dns_record3.ip }
          ],
          related_hostnames: [
            { hostname: "dolor.com", count: 1 },
            { hostname: "amet.com", count: 2 },
            { hostname: "ipsum.com", count: 1 }
          ]
        }

        expect(result).to eq(expected_result)
      end
    end
  end

  context 'when there are no records' do
    let(:params) { { included: 'nonexistent.com', page: 1 } }
    let(:dns_records_service) { described_class.new(params) }

    it 'returns an empty result' do
      result = dns_records_service.call

      expect(result[:total_records]).to eq(0)
      expect(result[:records]).to be_empty
      expect(result[:related_hostnames]).to be_empty
    end
  end
end
