# frozen_string_literal: true

RSpec.describe 'health', type: :request do
  it 'is ok' do
    get '/health'

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('text/html; charset=utf-8')

    expect(last_response.body).to include 'Status: ok'
  end

  it 'is json without .json extension' do
    get '/health', '', { 'HTTP_ACCEPT' => 'application/json' }

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('application/json; charset=utf-8')

    response_body = JSON.parse(last_response.body)

    expect(response_body).to eq({ 'status' => 'ok',
                                  'results' => [{ 'message' => '', 'name' => 'ORCID', 'status' => 'OK' }] })
  end

  it 'is json with .json extension' do
    get '/health.json'

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('application/json; charset=utf-8')

    response_body = JSON.parse(last_response.body)

    expect(response_body).to eq({ 'status' => 'ok',
                                  'results' => [{ 'message' => '', 'name' => 'ORCID', 'status' => 'OK' }] })
  end

  context 'ORCID api is down' do
    let(:bad) { instance_double(Net::HTTPBadGateway, code: '502') }
    let(:stub) { instance_double(Net::HTTP, "use_ssl=": true, "read_timeout=": true, get: bad) }
    before do
      allow(Net::HTTP).to receive(:new).and_return(stub)
    end

    it 'is json without .json extension' do
      get '/health', '', { 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response).to be_successful
      expect(last_response.content_type).to eq('application/json; charset=utf-8')

      response_body = JSON.parse(last_response.body)

      expect(response_body).to eq({ 'status' => 'error',
                                    'results' => [{ 'message' => 'The ORCID API returned HTTP error code: 502',
                                                    'name' => 'ORCID', 'status' => 'ERROR' }] })
    end
  end
end
