require 'airbrake/rails/controller_methods'

module Airbrake
  module Rails
    module ControllerMethods
      private

      def airbrake_request_data_with_user_attributes
        airbrake_request_data_without_user_attributes.merge(
          :user_attributes => Airbrake::CurrentUser.filtered_attributes(self)
        )
      end
      alias_method_chain :airbrake_request_data, :user_attributes

    end
  end
end
