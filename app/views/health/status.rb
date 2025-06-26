# frozen_string_literal: true

module OrcidPrinceton
  module Views
    module Health
      # combines all the dependencies statuses into a single JSON object
      class Status < OrcidPrinceton::View
        expose :current_status
      end
    end
  end
end
