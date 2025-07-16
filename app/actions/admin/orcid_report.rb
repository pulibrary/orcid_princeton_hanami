# frozen_string_literal: true

require 'securerandom'

module OrcidPrinceton
  module Actions
    module Admin
      # Serve up the ORCID report to Administrative users only
      class OrcidReport < OrcidPrinceton::Action
        include Deps['operations.people_soft_report']

        before :require_authentication # make sure there is a user logged in before serving the report
        before :require_admin # make sure the logged in user is an administrator

        def handle(_request, response)
          date = Time.now.strftime('%Y-%m-%d')
          user_filename = "ORCID_portal_report_#{date}.csv"
          file = Tempfile.new(SecureRandom.uuid)
          tmp_filename = file.path
          if people_soft_report.call(tmp_filename).is_a? Dry::Monads::Result::Success
            response.format = :csv
            response.headers['Content-Disposition'] = "inline; filename=\"#{user_filename}\""
            response.body = File.read(tmp_filename)
          end
          file.unlink
        end
      end
    end
  end
end
