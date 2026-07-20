# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module User
      # action to validate a user's ORCID tokens
      class ValidateTokens < OrcidPrinceton::Action
        include Deps['operations.validate_user_tokens',
                     alternative_view: 'views.errors.forbidden']

        before :require_authentication # make sure there is a user logged in before validating the tokens

        params do
          required(:id).value(:integer)
        end

        # rubocop:disable Metrics/MethodLength
        def handle(request, response)
          user_id = request.params[:id]
          if response[:current_user].id == user_id
            case validate_user_tokens.call(user_id)
            in Failure(error)
              response.flash[:notice] = error
            in Success
              nil
            end
            response.redirect_to routes.path(:user, id: response[:current_user].id)
          else
            response.render(alternative_view)
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
