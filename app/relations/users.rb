# frozen_string_literal: true

module OrcidPrinceton
  module Relations
    # for storing users and retrieving users from the database
    class Users < OrcidPrinceton::DB::Relation
      schema :users, infer: true
    end
  end
end
