# frozen_string_literal: true

module OrcidPrinceton
  module Relations
    # for storing the relation between users and roles
    class UsersRoles < OrcidPrinceton::DB::Relation
      schema :users_roles, infer: true do
        associations do
          belongs_to :user
          belongs_to :role
        end
      end
    end
  end
end
