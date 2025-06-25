# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Health
      # handles the /health route
      class Status < OrcidPrinceton::Action
        include Deps['views.health.status']

        format :html, :json

        def handle(request, response)
          if response.format == :json
            response.body = status.json_status.to_json
          end
        end
      end
    end
  end
end
