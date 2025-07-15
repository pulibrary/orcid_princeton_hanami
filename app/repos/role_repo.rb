# frozen_string_literal: true

module OrcidPrinceton
  module Repos
    # class for setting timestamps on roles
    class RoleRepo < OrcidPrinceton::DB::Repo
      def get(id)
        roles.by_pk(id).one!
      end

      def admin_role
        role = roles.where(name: 'admin')&.first
        if role.blank?
          role = create(name: 'admin')
        end
        role
      end

      def create(attributes)
        attributes[:created_at] = Time.now
        attributes[:updated_at] = Time.now
        roles.changeset(:create, attributes).commit
      end

      def update(attributes)
        attributes[:updated_at] = Time.now
        roles.changeset(:create, attributes).commit
      end

      def last = roles.last
    end
  end
end
