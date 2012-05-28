require 'airbrake/notice'

module Airbrake
  class Notice
    # User information
    # - Provides information about the currently logged in user
    attr_reader :user_attributes

    def initialize_with_user_attributes(args)
      self.user_attributes = args[:user_attributes] || {}
      initialize_without_user_attributes(args)
    end
    alias_method_chain :initialize, :user_attributes

    # Converts the given notice to XML
    # Need to override whole builder to add user-attributes at end.
    def to_xml
      builder = Builder::XmlMarkup.new
      builder.instruct!
      xml = builder.notice(:version => Airbrake::API_VERSION) do |notice|
        notice.tag!("api-key", api_key)
        notice.notifier do |notifier|
          notifier.name(notifier_name)
          notifier.version(notifier_version)
          notifier.url(notifier_url)
        end
        notice.error do |error|
          error.tag!('class', error_class)
          error.message(error_message)
          error.backtrace do |backtrace|
            self.backtrace.lines.each do |line|
              backtrace.line(:number => line.number,
                             :file   => line.file,
                             :method => line.method)
            end
          end
        end
        if url ||
            controller ||
            action ||
            !parameters.blank? ||
            !cgi_data.blank? ||
            !session_data.blank?
          notice.request do |request|
            request.url(url)
            request.component(controller)
            request.action(action)
            unless parameters.nil? || parameters.empty?
              request.params do |params|
                xml_vars_for(params, parameters)
              end
            end
            unless session_data.nil? || session_data.empty?
              request.session do |session|
                xml_vars_for(session, session_data)
              end
            end
            unless cgi_data.nil? || cgi_data.empty?
              request.tag!("cgi-data") do |cgi_datum|
                xml_vars_for(cgi_datum, cgi_data)
              end
            end
          end
        end
        notice.tag!("server-environment") do |env|
          env.tag!("project-root", project_root)
          env.tag!("environment-name", environment_name)
          env.tag!("hostname", hostname)
        end

        if user_attributes.present?
          notice.tag!("user-attributes") do |user|
            xml_vars_for(user, user_attributes)
          end
        end
      end

      xml.to_s
    end

    private

    attr_writer :user_attributes

  end
end
