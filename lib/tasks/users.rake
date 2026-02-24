# frozen_string_literal: true

require 'hanami/setup'

namespace :users do
  # TODO: Do we want this rake task in the future
  # desc "Adds a fake token to a user to emulate linking to ORCiD"
  # task :fake_orcid_link, [:netid] => [:environment] do |_, args|
  #   netid = args[:netid]
  #   user = User.where(uid: netid).first
  #   token_value = SecureRandom.hex
  #   expiration = DateTime.now + 30
  #   user_token = Token.new(user_id: user.id, token_type: "bearer", token: token_value, expiration:)
  #   user_token.save!
  #   puts "Added token #{token_value} to user #{netid}. Expiration: #{expiration}"
  # end

  # TODO: Do we want this rake task in the future
  # desc "Checks if an ORCiD token is valid for a given ORCiD"
  # task :check_orcid_token, [:token, :orcid] => [:environment] do |_, args|
  #   token = args[:token]
  #   orcid = args[:orcid]
  #   valid = Token.valid_in_orcid?(token, orcid)
  #   puts "Token #{token} is valid for ORCiD #{orcid}: #{valid}"
  # end

  desc 'Creates user records for the users defined as the default administrators'
  task create_admin_users: :environment do
    OrcidPrinceton::Repos::UserRepo.new.create_default_users
  end

  desc 'Deletes existing user roles and recreates the defaults.'
  task reset_default: :environment do
    users = OrcidPrinceton::Repos::UserRepo.new
    users.delete_all_roles
    users.create_default_users
  end

  desc 'load missing university ids from ldap'
  task load_university_ids: :environment do
    user_repo = OrcidPrinceton::Repos::UserRepo.new
    operation = OrcidPrinceton::Operations::UserFromAttributes.new
    blank_id_users = user_repo.users.where(university_id: nil)
    if blank_id_users.count.positive?
      puts "There are #{blank_id_users.count} blank university ids"
      blank_id_users.each do |user|
        operation.call(uid: user.uid,
                       access_token: OmniAuth::AuthHash.new(provider: 'cas',
                                                            uid: user.uid,
                                                            extra: OmniAuth::AuthHash.new))
      end
    else
      puts 'No ids need to be updated'
    end
  end
end
