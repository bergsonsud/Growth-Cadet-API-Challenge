require 'rails_helper'

RSpec.describe Api::V1::DnsRecordsController, type: :controller do
  let(:parsed_body) { JSON.parse(response.body, symbolize_names: true) }

  describe '#index' do
    context 'with the required page param' do
      let(:page) { 1 }

      let(:ip1) { '1.1.1.1' }
      let(:ip2) { '2.2.2.2' }
      let(:ip3) { '3.3.3.3' }
      let(:ip4) { '4.4.4.4' }
      let(:ip5) { '5.5.5.5' }
      let(:lorem) { 'lorem.com' }
      let(:ipsum) { 'ipsum.com' }
      let(:dolor) { 'dolor.com' }
      let(:amet) { 'amet.com' }
      let(:sit) { 'sit.com' }

      let(:payload1) do
        {
          dns_record: {
            ip: ip1,
            hostnames_attributes: [
              {
                hostname: lorem
              },
              {
                hostname: ipsum
              },
              {
                hostname: dolor
              },
              {
                hostname: amet
              }
            ]
          }
        }.to_json
      end

      let(:payload2) do
        {
          dns_record: {
            ip: ip2,
            hostnames_attributes: [
              {
                hostname: ipsum
              }
            ]
          }
        }.to_json
      end

      let(:payload3) do
        {
          dns_record: {
            ip: ip3,
            hostnames_attributes: [
              {
                hostname: ipsum
              },
              {
                hostname: dolor
              },
              {
                hostname: amet
              }
            ]
          }
        }.to_json
      end

      let(:payload4) do
        {
          dns_record: {
            ip: ip4,
            hostnames_attributes: [
              {
                hostname: ipsum
              },
              {
                hostname: dolor
              },
              {
                hostname: sit
              },
              {
                hostname: amet
              }
            ]
          }
        }.to_json
      end

      let(:payload5) do
        {
          dns_record: {
            ip: ip5,
            hostnames_attributes: [
              {
                hostname: dolor
              },
              {
                hostname: sit
              }
            ]
          }
        }.to_json
      end

      before do
        request.accept = 'application/json'
        request.content_type = 'application/json'

        post(:create, body: payload1, format: :json)
        post(:create, body: payload2, format: :json)
        post(:create, body: payload3, format: :json)
        post(:create, body: payload4, format: :json)
        post(:create, body: payload5, format: :json)
      end

      context 'without included and excluded optional params' do
        let(:expected_response) do
          {
            total_records: 5,
            records: [
              {
                id: 6,
                ip: ip1
              },
              {
                id: 7,
                ip: ip2
              },
              {
                id: 8,
                ip: ip3
              },
              {
                id: 9,
                ip: ip4
              },
              {
                id: 10,
                ip: ip5
              }
            ],
            related_hostnames: [
              {
                count: 1,
                hostname: lorem
              },
              {
                count: 4,
                hostname: ipsum
              },
              {
                count: 4,
                hostname: dolor
              },
              {
                count: 3,
                hostname: amet
              },
              {
                count: 2,
                hostname: sit
              }
            ]
          }
        end

        before :each do
          get(:index, params: { page: page })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns all dns records with all hostnames' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with the included optional param' do
        let(:included) { [ipsum, dolor].join(',') }

        let(:expected_response) do
          {
            total_records: 3,
            records: [
              {
                id: 16,
                ip: ip1
              },              
              {
                id: 18,
                ip: ip3
              },
              {
                id: 19,
                ip: ip4
              }
            ],
            related_hostnames: [
              {
                count: 3,
                hostname: ipsum
              },
              {
                count: 3,
                hostname: dolor
              }
            ]
          }
        end

        before :each do
          get(:index, params: { page: page, included: included })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the included dns records without a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with the excluded optional param' do
        let(:excluded) { [lorem].join(',') }

        let(:expected_response) do
          {
            total_records: 4,
            records: [
              {
                id: 27,
                ip: ip2
              },
              {
                id: 28,
                ip: ip3
              },
              {
                id: 29,
                ip: ip4
              },
              {
                id: 30,
                ip: ip5
              }
            ],
            related_hostnames: [
              {
                count: 3,
                hostname: ipsum
              },
              {
                count: 3,
                hostname: dolor
              },
              {
                count: 2,
                hostname: amet
              },
              {
                count: 2,
                hostname: sit
              }
            ]
          }
        end

        before :each do
          get(:index, params: { page: page, excluded: excluded })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the non-excluded dns records with a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with both included and excluded optional params' do
        let(:included) { [ipsum, dolor].join(',') }
        let(:excluded) { [sit].join(',') }

        let(:expected_response) do
          {
            total_records: 2,
            records: [
              {
                id: 36,
                ip: ip1
              },
              {
                id: 38,
                ip: ip3
              }
            ],
            related_hostnames: [              
              {
                count: 2,
                hostname: ipsum
              },
              {
                count: 2,
                hostname: dolor
              }
            ]
          }
        end

        before :each do
          get(:index, params: { page: page, included: included, excluded: excluded })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the non-excluded dns records with a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end
    end

    context 'without the required page param' do
      before :each do
        get(:index)
      end

      it 'responds with unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#create' do
    context 'with valid params' do
      let(:ip) { '192.168.1.1' }
      let(:hostname) { 'localhost.com' }

      let(:payload) do
        {
          dns_record: {
            ip: ip,
            hostnames_attributes: [
              {
                hostname: hostname
              }
            ]
          }
        }.to_json
      end

      before do
        request.accept = 'application/json'
        request.content_type = 'application/json'

        post(:create, body: payload, format: :json)
      end

      it 'responds with created status' do
        expect(response).to have_http_status(:created)
      end

      it 'creates a dns record' do
        expect(DnsRecord.count).to eq 1
      end

      it 'creates a hostname' do
        expect(Hostname.count).to eq 1
      end

      it 'creates a dns record with the correct ip' do
        expect(DnsRecord.first.ip).to eq ip
      end

      it 'creates a hostname with the correct hostname' do
        expect(Hostname.first.hostname).to eq hostname
      end

      it 'returns a success message' do
        expect(parsed_body).to eq({ message: 'DNS record created successfully' })
      end

      context 'with incorrect hostname' do
        let(:ip) { '192.168.1.1' }
        let(:hostname) { 'localhost_local' }
  
        let(:payload) do
          {
            dns_record: {
              ip: ip,
              hostnames_attributes: [
                {
                  hostname: hostname
                }
              ]
            }
          }.to_json
        end

        before do
          request.accept = 'application/json'
          request.content_type = 'application/json'

          post(:create, body: payload, format: :json)
        end

        it 'responds with unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a dns record' do
          expect(DnsRecord.count).to eq 0
        end

        it 'does not create a hostname' do
          expect(Hostname.count).to eq 0
        end

        it 'returns an error message' do
          expect(parsed_body).to eq({ errors: ['Hostnames hostname contains invalid characters (valid characters: [a-z0-9\\-])'] })
        end
      end
      
    end
  end
end
