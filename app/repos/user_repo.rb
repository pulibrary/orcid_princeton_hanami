# frozen_string_literal: true

module OrcidPrinceton
  module Repos
    # class for accessing the users in the system
    class UserRepo < OrcidPrinceton::DB::Repo
      def get(id)
        users.by_pk(id).one!
      end

      def create(attributes)
        time_now = Time.now
        attributes[:created_at] = time_now
        attributes[:updated_at] = time_now
        users.changeset(:create, attributes).commit
      end

      def update(id, attributes)
        attributes[:updated_at] = Time.now
        users.by_pk(id).changeset(:update, attributes).commit
      end

      def last = users.last
    end
  end
end
