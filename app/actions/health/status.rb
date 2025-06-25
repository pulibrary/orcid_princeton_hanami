# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Health
      # handles the /health route
      class Status < OrcidPrinceton::Action
        format :html
        def handle(request, response); end
      end
    end
  end
end
