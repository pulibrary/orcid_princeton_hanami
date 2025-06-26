# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Health
      # handles the /health route
      class Status < OrcidPrinceton::Action
        include Deps['views.health.status']

        format :html, :json

        before :set_format_for_json_extension

        def handle(_request, response)
          if response.format == :json
            response.body = status.json_status.to_json
          end
        end

        private

        def set_format_for_json_extension(request, response)
          if request.path.end_with?('.json')
            response.format = :json
          end
        end
      end
    end
  end
end
