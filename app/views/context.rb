# frozen_string_literal: true

module OrcidPrinceton
  module Views
    # context to expose methods to the templates
    class Context < Hanami::View::Context
      include Deps['repos.user_repo']

      def current_user
        return nil if session[:current_user].nil?

        @current_user ||= user_repo.find_by_uid(session[:current_user])
      end
    end
  end
end
