# auto_register: false
# frozen_string_literal: true

require 'hanami/view'

require 'tilt/jbuilder'

Tilt.register Tilt[:jbuilder], :json

module OrcidPrinceton
  # Base Hanami view for the ORCID application
  class View < Hanami::View
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
      result = orcid_api_status.call
      result.instance_of?(Dry::Monads::Result::Success)
    end

    # Disables layout when rendering with `format: :json` option
    def call(format: :html, **options)
      if format == :json
        super(**options, format:, layout: nil)
      else
        super
      end
    end
  end
end
