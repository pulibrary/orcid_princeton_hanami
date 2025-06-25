# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Health
      # handles the /health.json route
      class JSON < OrcidPrinceton::Action
        include Deps['views.health.status']
        format :json
        def handle(_request, response)
          response.format = :json
          response.body = status.json_status.to_json
        end
      end
    end
  end
end
