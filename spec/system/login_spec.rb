# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Login link is part of the layout', type: :system, js: true do
  it 'has the login link' do
    visit '/health'
    expect(page).to have_link 'Login'
  end

  context 'a user is logged in' do
    let(:user) { Factory[:user] }

    it 'shows the logged in user info' do
      login_as user.uid
      visit '/health'
      expect(page).to have_content user.display_name
    end
  end
end
