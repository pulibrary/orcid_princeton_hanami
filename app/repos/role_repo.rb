# frozen_string_literal: true

module OrcidPrinceton
  module Repos
    # class for setting timestamps on roles
    class RoleRepo < OrcidPrinceton::DB::Repo
      def get(id)
        roles.by_pk(id).one!
      end

      def delete_all
        roles.changeset(:delete).commit
      end

      def admin_role
        role = roles.where(name: 'admin')&.first
        if role.blank?
          role = create(name: 'admin')
        end
        role
      end

      def create(attributes)
        time_now = Time.now
        attributes[:created_at] = time_now
        attributes[:updated_at] = time_now
        roles.changeset(:create, attributes).commit
      end

      def update(id, attributes)
        attributes[:updated_at] = Time.now
        roles.by_pk(id).changeset(:update, attributes).commit
        get(id)
      end

      def last = roles.last
    end
  end
end
