# frozen_string_literal: true

module OrcidPrinceton
  module Structs
    # ruby object for all the information we need to generate a row of the peoplesoft report
    #  Remember that dry structs do not allow for mutation so there are no setters only getters
    class PeopleSoftRow < Dry::Struct
      attribute :effective_from, Types::String
      attribute :effective_until, Types::String
      attribute :full_name, Types::String
      attribute :netid, Types::String
      attribute :orcid, Types::String
      attribute :row_type, Types::String.default('ORC')
      attribute :university_id, Types::String.optional

      class << self
        def new_from_user(user)
          PeopleSoftRow.new(university_id: user.university_id,
                            netid: user.uid,
                            full_name: user.display_name,
                            orcid: user.orcid,
                            effective_from: user.valid_token.created_at.strftime('%m/%d/%Y'),
                            effective_until: user.valid_token.expiration.strftime('%m/%d/%Y'))
        end
      end
    end
  end
end
