# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module User
      # action to load and show a user
      class Show < OrcidPrinceton::Action
        include Deps['repos.user_repo',
                     alternative_view: 'views.errors.forbidden',
                     valid_view: 'views.user.show' ]
        before :require_authentication # make sure there is a user logged in before serving the report

        format :html, :json

        before :set_format_for_json_extension

        params do
          required(:id).value(:string)
        end

        def handle(request, response)
          user_id = request.params[:id].split('.').first.to_i
          if response[:current_user].id == user_id
            response[:user] = user_repo.get(user_id)
            response.render(valid_view, format: response.format)
          else
            response.render(alternative_view)
          end
        end

        private

        def set_format_for_json_extension(request, response)
          if request.params[:id].to_s.end_with?('.json')
            response.format = :json
          end
        end
      end
    end
  end
end
