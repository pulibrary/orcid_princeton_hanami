# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Orcid Link deny', type: :system, js: true do
  let(:user) { Factory[:user] }
  it 'when the callback is a deny' do
    pending 'We have a orcid callback action'
    login_as user.uid
    visit '/auth/orcid/callback?error=access_denied&' \
          'error_description=User%20denied%20access&state=78b44659eab7947a023cf512b13c32253c8fa320d5491a2c'
    expect(page).to have_content 'Consider linking'
  end
end
