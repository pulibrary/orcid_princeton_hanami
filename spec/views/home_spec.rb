# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Views::Home::Show do
  let(:view) { described_class.new }
  let(:user) { Factory[:user] }
  let(:version_hash) do
    { stale: false, sha: 'sha', branch: 'v0.8.0', version: '10 December 2021', tagged_release: true }
  end
  subject(:rendered) { view.call(current_user: user, code_version: version_hash) }

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
