module Airbrake
  module CurrentUser

    # Returns filtered attributes for current user
    def self.filtered_attributes(controller)
      return {} unless controller.respond_to?(:current_user, true)
      user = controller.send(:current_user)
      # Removes auth-related fields
      attributes = user.attributes.reject do |k, v|
        /password|token|login|sign_in|per_page|_at$/ =~ k
      end
      # Try to include a URL for the user, if possible.
      if url_method = [:user_url, :admin_user_url].detect {|m| controller.respond_to?(m) }
        attributes[:url] = controller.send(url_method, user)
      end
      # Return all keys with non-blank values
      attributes.select {|k,v| v.present? }
    end

  end
end
