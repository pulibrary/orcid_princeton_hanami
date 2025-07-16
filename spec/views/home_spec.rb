# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Views::Home::Show do
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
  let(:context) do
    Hanami::View::Context.new(request:, inflector: default_context.inflector,
                              assets: default_context.assets, settings: default_context.settings,
                              routes: default_context.routes)
  end

  subject(:rendered) { view.call(current_user: user, code_version: version_hash, context:) }

  it 'exposes current_user' do
    expect(rendered[:current_user].value).to eq(user)
  end

  it 'exposes code_version hash' do
    expect(rendered[:code_version].value).to eq(version_hash)
  end

  it 'exposes code_version_name' do
    expect(rendered[:code_version_name].value).to(
      eq('<a href="https://github.com/pulibrary/orcid_princeton_hanami/releases/tag/v0.8.0" target="_blank">v0.8.0</a>')
    )
  end

  it 'exposes stale_version as empty string' do
    expect(rendered[:stale_version].value).to eq('')
  end

  context 'the version is stale and is not released' do
    let(:version_hash) do
      { stale: true, sha: 'sha', branch: 'v0.8.0', version: '10 December 2021', tagged_release: false }
    end

    it 'exposes code_version hash' do
      expect(rendered[:code_version].value).to eq(version_hash)
    end

    it 'exposes code_version_name' do
      expect(rendered[:code_version_name].value).to(
        eq('v0.8.0')
      )
    end

    it 'exposes stale_version as empty string' do
      expect(rendered[:stale_version].value).to eq('(stale)')
    end
  end
end
