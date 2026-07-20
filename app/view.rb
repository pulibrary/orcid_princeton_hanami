# auto_register: false
# frozen_string_literal: true

require 'hanami/view'
require 'dry/monads'

require 'tilt/jbuilder'

Tilt.register Tilt[:jbuilder], :json

module OrcidPrinceton
  # Base Hanami view for the ORCID application
  class View < Hanami::View
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]

    include Deps['operations.orcid_api_status']

    expose :current_user, layout: true
    expose :code_version, layout: true

    expose :code_version_name, layout: true do |code_version|
      if code_version[:tagged_release]
        "<a href=\"https://github.com/pulibrary/orcid_princeton_hanami/releases/tag/#{code_version[:branch]}\" " \
          "target=\"_blank\">#{code_version[:branch]}</a>"
      else
        code_version[:branch]
      end
    end

    expose :stale_version, layout: true do |code_version|
      if code_version[:stale]
        '(stale)'
      else
        ''
      end
    end

    expose :orcid_available do
      case orcid_api_status.call
      in Success
        true
      in Failure
        false
      end
    end

    expose :banner_title, layout: true do
      Hanami.app.settings.banner_title
    end
    expose :banner_body, layout: true do
      Hanami.app.settings.banner_body
    end

    # Disables layout when rendering with `format: :json` option
    def call(format: :html, **options)
      if format == :json
        super(**options, format:, layout: nil)
      else
        super
      end
    end

    expose :login_url, layout: true do
      if Hanami.app.settings.use_entra
        '/auth/entra_id'
      else
        '/auth/cas'
      end
    end
  end
end
