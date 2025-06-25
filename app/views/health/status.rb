# frozen_string_literal: true

module OrcidPrinceton
  module Views
    module Health
      # combines all the dependencies statuses into a single JSON object
      class Status < OrcidPrinceton::View
        include Deps['operations.orcid_api_status']

        expose :current_status do
          json_status
        end

        def json_status
          case orcid_api_status.call
          in Dry::Monads::Result::Success(orcid_status)
            { status: 'OK', results: [{ name: 'ORCID', message: '', status: 'OK' }] }
          in Dry::Monads::Result::Failure[:invalid, error]
            { status: 'ERROR', results: [{ name: 'ORCID', message: error, status: 'ERROR' }] }
          end
        end
      end
    end
  end
end
