# frozen_string_literal: true

require 'net/http'
require 'net/ldap'
require 'honeybadger'

module OrcidPrinceton
  module Operations
    # Converts the cas token into a user
    class UserFromAttributes < OrcidPrinceton::Operation
      include Deps['repos.user_repo']

      def call(uid:, access_token:)
        user_attributes = step basic_user_attributes(uid:, access_token:)
        final_attributes = step add_ldap_attributes(uid:, combined_attributes: user_attributes, access_token:)

        if user_attributes[:id].nil?
          step create(final_attributes)
        else
          step update(final_attributes)
        end
      end

      private

      def basic_user_attributes(uid:, access_token:)
        user_attributes = model_attributes(uid)
        combined_attributes = if user_attributes[:given_name].nil? || user_attributes[:given_name].empty?
                                token_attributes = attributes_from_token(access_token)
                                merge_attributes(token_attributes, user_attributes)
                              else
                                user_attributes
                              end
        Success(combined_attributes)
      end

      def add_ldap_attributes(uid:, combined_attributes:, access_token:)
        return Success(combined_attributes) unless combined_attributes[:university_id].nil?

        Honeybadger.notify("Getting information for user #{uid} from ldap.  Token #{access_token}")
        ldap_attr = ldap_info(uid)
        if ldap_attr.nil? || ldap_attr.universityid.nil?
          Failure("Can not find the university id for #{uid}")
        else
          result = merge_attributes(combined_attributes, ldap_attributes(ldap_attr))

          Success(result)
        end
      end

      def create(attributes)
        result = user_repo.create(attributes)
        Success(result)
      end

      def update(attributes)
        result = user_repo.update(attributes[:id], attributes)
        Success(result)
      end

      def model_attributes(uid)
        user = user_repo.find_by_uid(uid)
        if user.nil?
          { uid: uid }
        else
          user.attributes
        end
      end

      def attributes_from_token(access_token)
        alternate_value = alternate_value(access_token.uid, access_token.extra.universityid)
        { university_id: access_token.extra.universityid,
          email: access_token.extra.mail, provider: access_token.provider.to_s,
          given_name: access_token.extra.givenname || alternate_value,
          family_name: access_token.extra.sn || alternate_value,
          display_name: access_token.extra.displayname || alternate_value }
      end

      def alternate_value(uid, university_id)
        # We will take the alternate from ldap
        if university_id.nil?
          nil
        # We will not access ldap, so lets take the uid as an alternate
        else
          uid
        end
      end

      def merge_attributes(primary_attributes, secondary_attributes)
        primary_attributes.merge(secondary_attributes) { |_key, oldval, newval| oldval || newval }
      end

      def ldap_info(uid)
        filter = Net::LDAP::Filter.eq('uid', uid)
        default_connection.search(filter: filter).first
      end

      def ldap_attributes(ldap_attr)
        { uid: ldap_attr[:uid].first, university_id: ldap_attr[:universityid].first,
          email: ldap_attr[:mail].first, provider: 'cas',
          given_name: ldap_attr[:givenname].first,
          family_name: ldap_attr[:sn].first,
          display_name: ldap_attr[:displayname].first }
      end

      def default_connection
        @default_connection ||=
          Net::LDAP.new(
            host: 'ldap.princeton.edu',
            base: 'o=Princeton University,c=US',
            port: 636,
            encryption: {
              method: :simple_tls,
              tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
            }
          )
      end
    end
  end
end
