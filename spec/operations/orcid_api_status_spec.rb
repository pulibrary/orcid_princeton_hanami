# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Operations::OrcidAPIStatus do
  it 'checks the status' do
    status = described_class.new
    result = status.call
    expect(result).to be_a Dry::Monads::Result::Success
  end

  context 'when the api is showing a failed component' do
    let(:failure_resp) do
      instance_double(Net::HTTPOK, code: '200',
                                   body: '{"tomcatUp":false,"dbConnectionOk":true,'\
                                         '"readOnlyDbConnectionOk":true,"overallOk":true}')
    end
    let(:stub) { instance_double(Net::HTTP, "use_ssl=": true, "read_timeout=": true, get: failure_resp) }
    before do
      allow(Net::HTTP).to receive(:new).and_return(stub)
    end
    it 'raises an error when the status is checked' do
      status = described_class.new
      result = status.call
      expect(result).to be_a Dry::Monads::Result::Failure
      expect(result.failure).to eq('The ORCID API has an invalid status https://api.orcid.org/v3.0/apiStatus')
    end
  end

  context 'when the api errors' do
    let(:bad) { instance_double(Net::HTTPBadGateway, code: '502') }
    let(:stub) { instance_double(Net::HTTP, "use_ssl=": true, "read_timeout=": true, get: bad) }
    before do
      allow(Net::HTTP).to receive(:new).and_return(stub)
    end
    it 'raises an error when the status is checked' do
      status = described_class.new
      result = status.call
      expect(result).to be_a Dry::Monads::Result::Failure
      expect(result.failure).to eq('The ORCID API returned HTTP error code: 502')
    end
  end

  context 'when the api errors and then is ok' do
    let(:stub) { instance_double(Net::HTTP, "use_ssl=": true, "read_timeout=": true) }
    let(:bad) { instance_double(Net::HTTPBadGateway, code: '502') }
    let(:ok_resp) do
      instance_double(Net::HTTPOK, code: '200',
                                   body: '{"tomcatUp":true,"dbConnectionOk":true,'\
                                         '"readOnlyDbConnectionOk":true,"overallOk":true}')
    end
    before do
      allow(Net::HTTP).to receive(:new).and_return(stub)
      allow(stub).to receive(:get).and_return(bad, ok_resp)
    end
    it 'does not raise an error when the status is checked' do
      status = described_class.new
      result = status.call
      expect(result).to be_a Dry::Monads::Result::Success
    end
  end
end
