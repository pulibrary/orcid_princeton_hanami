# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Health::JSON do
  let(:params) { {} }

  it 'works' do
    response = subject.call(params)
    expect(response).to be_successful
  end
end
