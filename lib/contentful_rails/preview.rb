module ContentfulRails
  module Preview
    extend ActiveSupport::Concern

    included do
      before_action :check_preview_domain
    end
    # Check whether the subdomain being presented is the preview domain.
    # If so, set ContentfulModel to use the preview API, and request a username / password
    def check_preview_domain
      # If enable_preview_domain is not enabled, explicitly set use_preview_api false and return
      unless ContentfulRails.configuration.enable_preview_domain
        ContentfulModel.use_preview_api = false
        return
      end

      #check subdomain matches the configured one
      if request.subdomain == ContentfulRails.configuration.preview_domain
        authenticated = authenticate_with_http_basic  do |u,p|
          u == ContentfulRails.configuration.preview_username
          p == ContentfulRails.configuration.preview_password
        end
        # If user is authenticated, we're good to switch to the preview api
        if authenticated
          ContentfulModel.use_preview_api = true
        else
          #otherwise ask for user / pass
            request_http_basic_authentication
        end
      else
        #if the subdomain doesn't match the configured one, explicitly set to false
        ContentfulModel.use_preview_api = false
        return
      end

    end
  end
end