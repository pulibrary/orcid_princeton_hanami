# frozen_string_literal: true

RSpec.describe 'header and footer', type: :system, js: true do
  it 'shows the system name in the footer' do
    visit '/'
    expect(page).to have_content('ORCID@Princeton')
  end

  it 'shows the version in the footer' do
    visit '/'
    expect(page).to have_content('Version: ')
  end
end
