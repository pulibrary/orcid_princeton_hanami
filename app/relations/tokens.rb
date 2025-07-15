# frozen_string_literal: true

module OrcidPrinceton
  module Relations
    # for storing tokens and retrieving tokens from the database
    class Tokens < OrcidPrinceton::DB::Relation
      schema :tokens, infer: true do
        associations do
          belongs_to :user
        end
      end
    end
  end
end
