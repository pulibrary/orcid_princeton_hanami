# frozen_string_literal: true

require 'honeybadger'

RSpec.describe OrcidPrinceton::Actions::Session::Failure do
  let(:params) { { message: 'Authentication failed' } }

  it 'works' do
    allow(Honeybadger).to receive(:notify)
    response = subject.call(params)
    expect(response).to be_redirect
    expect(Honeybadger).to have_received(:notify).with('Authentication failure: Authentication failed')
  end
end
