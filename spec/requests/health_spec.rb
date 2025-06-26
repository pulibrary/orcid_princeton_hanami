# frozen_string_literal: true

RSpec.describe 'health', type: :request do
  it 'is ok' do
    get '/health'

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('text/html; charset=utf-8')

    expect(last_response.body).to include 'Status: OK'
  end

  it 'is json without .json extension' do
    get '/health', '', { 'HTTP_ACCEPT' => 'application/json' }

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('application/json; charset=utf-8')

    response_body = JSON.parse(last_response.body)

    expect(response_body).to eq({ 'status' => 'OK',
                                  'results' => [{ 'message' => '', 'name' => 'ORCID', 'status' => 'OK' }] })
  end

  it 'is json with .json extension' do
    get '/health.json'

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('application/json; charset=utf-8')

    response_body = JSON.parse(last_response.body)

    expect(response_body).to eq({ 'status' => 'OK',
                                  'results' => [{ 'message' => '', 'name' => 'ORCID', 'status' => 'OK' }] })
  end
end
