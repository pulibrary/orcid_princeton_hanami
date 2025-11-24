# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Views::User::Show do
  let(:view) { described_class.new }
  let(:rom_user) { Factory[:user] }
  let(:user) { OrcidPrinceton::Repos::UserRepo.new.get(rom_user.id) }
  let(:version_hash) do
    { stale: false, sha: 'sha', branch: 'v0.8.0', version: '10 December 2021', tagged_release: true }
  end

  # create a context that can handle the flash message by setting the request
  # TODO:  This seems really hard.  I wonder if there is a better way...
  let(:rack_request) { Rack::MockRequest.env_for('http://example.com/') }
  let(:request) { Hanami::Action::Request.new(env: rack_request, params: {}, session_enabled: true) }
  let(:default_context) { OrcidPrinceton::Views::Home::Show.config.values[:default_context] }
  let(:settings) { Hanami.app.settings }
  let(:context) do
    Hanami::View::Context.new(request:, inflector: default_context.inflector,
                              assets: default_context.assets,
                              routes: default_context.routes)
  end

  subject(:rendered) { view.call(user: user, current_user: user, code_version: version_hash, context:) }

  it 'exposes orcid_url' do
    expect(rendered[:orcid_url].value).to eq('https://sandbox.orcid.org/')
  end

  context 'not the sandbox' do
    it 'exposes orcid_url' do
      allow(settings).to receive(:orcid_sandbox).and_return(false)
      expect(rendered[:orcid_url].value).to eq('https://orcid.org/')
    end
  end
end
