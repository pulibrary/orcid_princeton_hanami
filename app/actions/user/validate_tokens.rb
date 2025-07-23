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

        def handle(request, response)
          user_id = request.params[:id]
          if response[:current_user].id == user_id
            result = validate_user_tokens.call(user_id)
            if result in Dry::Monads::Result::Failure(error)
              response.flash[:notice] = error
            end
            response.redirect_to routes.path(:user, id: response[:current_user].id)
          else
            response.render(alternative_view)
          end
        end
      end
    end
  end
end
