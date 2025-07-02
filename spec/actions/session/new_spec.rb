# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Session::New do
  let(:params) { {} }

  it 'works' do
    response = subject.call(params)
    expect(response).to be_redirect
  end
end
