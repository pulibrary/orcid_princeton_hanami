# frozen_string_literal: true

module OrcidPrinceton
  module Relations
    # for storing users and retrieving users from the database
    class Users < OrcidPrinceton::DB::Relation
      schema :users, infer: true do
        associations do
          has_many :users_roles
          has_many :roles, through: :users_roles
          has_many :tokens
        end
      end
    end
  end
end
