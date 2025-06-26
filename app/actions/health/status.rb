# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Health
      # handles the /health route
      class Status < OrcidPrinceton::Action
        include Deps['operations.orcid_api_status']

        format :html, :json

        before :set_format_for_json_extension

        def handle(_request, response)
          current_status = retrieve_orcid_id_status

          if response.format == :json
            response.body = current_status.to_json
          else
            response[:current_status] = current_status
          end
        end

        private

        def set_format_for_json_extension(request, response)
          if request.path.end_with?('.json')
            response.format = :json
          end
        end

        def retrieve_orcid_id_status
          case orcid_api_status.call
          in Dry::Monads::Result::Success(_orcid_status)
            { status: 'OK', results: [{ name: 'ORCID', message: '', status: 'OK' }] }
          in Dry::Monads::Result::Failure[:invalid, error]
            { status: 'ERROR', results: [{ name: 'ORCID', message: error, status: 'ERROR' }] }
          end
        end
      end
    end
  end
end
