module Airbrake
  class << self
    private

    def build_notice_for_with_current_user(exception, opts = {})
      if opts[:rack_env] && controller = opts[:rack_env]['action_controller.instance']
        opts[:user_attributes] = Airbrake::CurrentUser.filtered_attributes(controller)
      end
      build_notice_for_without_current_user(exception, opts)
    end
    alias_method_chain :build_notice_for, :current_user

  end
end
