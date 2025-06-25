# frozen_string_literal: true
require "spec_helper"

RSpec.describe "user experience from start to finish", type: :system, js: true do
  context "a user without an orcid on file" do
    let(:user) { Factory[:user] }
    let(:user2) { Factory[:user] }
    let(:orcid_identifier) { (Factory.structs[:user_with_orcid]).orcid }
    it "walks the user through the process of entering an ORCID and creating a token" do
      pending "We have a user model"
      login_as user

      # The user is redirected to the user edit screen after logging in.
      # The user has no orcid identifier or token yet.
      visit "/"

      # The main page has a banner for annoucements
      expect(page).to have_css "#banner"

      # The page should be accessible.
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508, :"best-practice")
      expect(page).to have_content(user.display_name)
      # Expand the user menu dropdown
      click_on user.display_name.to_s
      click_on "Profile"

      # The user is redirected to the user page after logging in.
      expect(page).to have_content "Welcome, #{user.display_name}"

      # The user page has a banner for annoucements and is accessible.
      expect(page).to have_css "#banner"
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508, :"best-practice")

      expect(page).to have_content "There is no ORCID iD associated with your NetID"
      expect(page).to have_content "This button will take you to ORCID to sign and and will add Princeton University as a Trusted Organization."
      expect(page).to have_content "This will allow Princeton University to read your ORCID record and add information to it."
      expect(page).to have_button "Connect ORCID iD"
      expect(page).to have_link "Step by Step Tutorial"

      # Trying to access the page of another user should be forbidden.
      visit "/users/#{user2.id}"
      expect(page).to have_content "Forbidden"
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508, :"best-practice")
    end
  end
  context "when a user has an expired token" do
    let(:user) { Factory[:user_with_expired_token] }
    it "lets them know their token is expired" do
      pending "We have a user model"
      login_as user
      visit "/users/#{user.id}"
      expect(page).to have_content "Your ORCID token has expired"
      expect(page).not_to have_content "There is no ORCID iD associated with your NetID"
    end
  end

  context "when a user has a valid token" do
    let(:user) { Factory[:user_with_orcid_and_token] }
    it "displays the token with an expiration date" do
      pending "We have a user model"
      login_as user
      visit "/users/#{user.id}"
      expect(page).to have_content "is connected to your NetID"
      expect(page).to have_content "grants Princeton access to read and update your ORCID record"
    end
  end

  context "when a banner is not present" do
    before do
      # TODO: I'm unsure how to set different settings in the tests
      ENV["BANNER"] = ""
    end

    it "shows no banner and is axe clean" do
      pending "We have a home page"
      visit "/"

      # The main page has a banner for annoucements
      expect(page).not_to have_css "#banner"

      # The page should be accessible.
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508, :"best-practice")
    end
  end

  context "an administrator user" do
    let(:user) { Factory[:admin] }

    it "walks the user through the process of entering an ORCID and creating a token" do
      pending "We have a user model"
      login_as(user)
      visit "/"
      click_on "Profile"

      expect(page).to have_content "Welcome, #{user.display_name} (Administrator)"
    end

    it "allows ORCID Report download menu option" do
      pending "We have a user model"
      login_as user
      visit "/"
      page.find(:css, ".lux-submenu-toggle").click
      expect(page).to have_link "ORCID Report"
    end
  end

  context "a non-administrator user" do
    let(:user) { Factory[:user] }

    it "does not allow the ORCID Report download menu option" do
      pending "We have a user model"
      login_as user
      visit "/"
      page.find(:css, ".lux-submenu-toggle").click
      expect(page).not_to have_link "ORCID Report"
    end
  end
end
