# frozen_string_literal: true

module OrcidPrinceton
  module Relations
    # for storing roles and retrieving roles from the database
    class Roles < OrcidPrinceton::DB::Relation
      schema :roles, infer: true do
        associations do
          has_many :users_roles
          has_many :users, through: :users_roles
        end
      end
    end
  end
end
