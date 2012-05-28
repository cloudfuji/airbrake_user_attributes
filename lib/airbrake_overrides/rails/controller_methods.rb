require 'airbrake/rails/controller_methods'

module Airbrake
  module Rails
    module ControllerMethods

      def airbrake_request_data_with_user_attributes
        data = airbrake_request_data_without_user_attributes
        data[:user_attributes] = current_user_filtered_attributes if respond_to?(:current_user)
        data
      end
      alias_method_chain :airbrake_request_data, :user_attributes

      private

      # Returns filtered attributes for current user (removes auth-related fields)
      def current_user_filtered_attributes
        attributes = current_user.attributes.reject do |k, v|
          /password|token|login|sign_in|per_page|_at$/ =~ k
        end
        # Try to include a URL for the user, if possible.
        if url_method = [:user_url, :admin_user_url].detect {|m| respond_to?(m) }
          attributes[:url] = send(url_method, current_user)
        end
        attributes
      end

    end
  end
end

