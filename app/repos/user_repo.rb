# frozen_string_literal: true

module OrcidPrinceton
  module Repos
    # class for accessing the users in the system
    class UserRepo < OrcidPrinceton::DB::Repo
      def get(id)
        user_with_roles.by_pk(id).one!
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
        get(id)
      end

      def last = user_with_roles.last

      def find_by_uid(uid)
        user_with_roles.where(uid: uid)&.first
      end

      def from_cas(access_token)
        return nil if access_token.nil?

        user = find_by_uid(access_token.uid)
        # create and persist the new model
        if user.nil?
          create(token_to_attributes(access_token))
        elsif user.given_name.nil? || user.given_name.empty?
          update(user.id, token_to_attributes(access_token))
        else
          user
        end
      end

      def user_with_roles
        users.combine(:roles)
      end

      private

      def token_to_attributes(access_token)
        { uid: access_token.uid, university_id: access_token.universityid,
          email: access_token.extra.mail, provider: access_token.provider,
          given_name: access_token.extra.givenname || access_token.uid,
          family_name: access_token.extra.sn || access_token.uid,
          display_name: access_token.extra.displayname || access_token.uid }
      end
    end
  end
end
