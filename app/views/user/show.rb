# frozen_string_literal: true

module OrcidPrinceton
  module Views
    module User
      # class to display user information
      class Show < OrcidPrinceton::View
        expose :user

        expose :dom_id do |user|
          "user_#{user.id}"
        end

        expose :orcid_url do |user|
          "#{Hanami.app.settings.orcid_url}/#{user.orcid}"
        end

        expose :user_url do |user|
          Hanami.app.router.url(:user_json, id: user.id)
        end

        expose :token_prompt do |token_empty, token_expired, user|
          prompt = if token_empty
                     "There is no ORCID iD associated with your NetID, #{user.uid}"
                   elsif token_expired
                     'Your ORCID token has expired. Please click the button below to ' \
                       're-authorize Princeton University to access your ORCID record.'
                   else
                     ''
                   end
          prompt
        end

        expose :token_expired do |user, orcid_available|
          user.tokens_expired? && orcid_available
        end

        expose :token_empty do |user|
          user.orcid.nil? || user.orcid.empty? || user.tokens.count.zero?
        end
      end
    end
  end
end
