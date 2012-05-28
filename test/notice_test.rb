require File.dirname(__FILE__) + '/helper'

class NoticeTest < Test::Unit::TestCase

  include DefinesConstants

  def configure
    Airbrake::Configuration.new.tap do |config|
      config.api_key = 'abc123def456'
    end
  end

  def build_notice(args = {})
    configuration = args.delete(:configuration) || configure
    Airbrake::Notice.new(configuration.merge(args))
  end

  def stub_request(attrs = {})
    stub('request', { :parameters  => { 'one' => 'two' },
                      :protocol    => 'http',
                      :host        => 'some.host',
                      :request_uri => '/some/uri',
                      :session     => { :to_hash => { 'a' => 'b' } },
                      :env         => { 'three' => 'four' } }.update(attrs))
  end

  def hostname
    `hostname`.chomp
  end

  def assert_valid_notice_document(document)
    xsd_path = File.join(File.dirname(__FILE__), "airbrake_2_2.xsd")
    schema = Nokogiri::XML::Schema.new(IO.read(xsd_path))
    errors = schema.validate(document)
    assert errors.empty?, errors.collect{|e| e.message }.join
  end

  context "a Notice turned into XML" do
    setup do
      Airbrake.configure do |config|
        config.api_key = "1234567890"
      end

      @exception = build_exception

      @notice = build_notice({
        :notifier_name    => 'a name',
        :notifier_version => '1.2.3',
        :notifier_url     => 'http://some.url/path',
        :exception        => @exception,
        :controller       => "controller",
        :action           => "action",
        :url              => "http://url.com",
        :parameters       => { "paramskey"     => "paramsvalue",
                               "nestparentkey" => { "nestkey" => "nestvalue" } },
        :session_data     => { "sessionkey" => "sessionvalue" },
        :cgi_data         => { "cgikey" => "cgivalue" },
        :user_attributes  => { "id" => 1234, "username" => "jsmith", "url" => "http://www.example.com/users/1234" },
        :project_root     => "RAILS_ROOT",
        :environment_name => "RAILS_ENV"
      })

      @xml = @notice.to_xml

      @document = Nokogiri::XML::Document.parse(@xml)
    end

    should "validate against the XML schema" do
      assert_valid_notice_document @document
    end

    should "serialize a Notice to XML when sent #to_xml" do
      assert_valid_node(@document, "//api-key", @notice.api_key)

      assert_valid_node(@document, "//notifier/name",    @notice.notifier_name)
      assert_valid_node(@document, "//notifier/version", @notice.notifier_version)
      assert_valid_node(@document, "//notifier/url",     @notice.notifier_url)

      assert_valid_node(@document, "//error/class",   @notice.error_class)
      assert_valid_node(@document, "//error/message", @notice.error_message)

      assert_valid_node(@document, "//error/backtrace/line/@number", @notice.backtrace.lines.first.number)
      assert_valid_node(@document, "//error/backtrace/line/@file", @notice.backtrace.lines.first.file)
      assert_valid_node(@document, "//error/backtrace/line/@method", @notice.backtrace.lines.first.method)

      assert_valid_node(@document, "//request/url",        @notice.url)
      assert_valid_node(@document, "//request/component", @notice.controller)
      assert_valid_node(@document, "//request/action",     @notice.action)

      assert_valid_node(@document, "//request/params/var/@key",     "paramskey")
      assert_valid_node(@document, "//request/params/var",          "paramsvalue")
      assert_valid_node(@document, "//request/params/var/@key",     "nestparentkey")
      assert_valid_node(@document, "//request/params/var/var/@key", "nestkey")
      assert_valid_node(@document, "//request/params/var/var",      "nestvalue")
      assert_valid_node(@document, "//request/session/var/@key",    "sessionkey")
      assert_valid_node(@document, "//request/session/var",         "sessionvalue")
      assert_valid_node(@document, "//request/cgi-data/var/@key",   "cgikey")
      assert_valid_node(@document, "//request/cgi-data/var",        "cgivalue")

      assert_valid_node(@document, "//server-environment/project-root",     "RAILS_ROOT")
      assert_valid_node(@document, "//server-environment/environment-name", "RAILS_ENV")
      assert_valid_node(@document, "//server-environment/hostname", hostname)

      assert_valid_node(@document, "//user-attributes/var/@key", "id")
      assert_valid_node(@document, "//user-attributes/var",      "1234")
      assert_valid_node(@document, "//user-attributes/var/@key", "username")
      assert_valid_node(@document, "//user-attributes/var",      "jsmith")
      assert_valid_node(@document, "//user-attributes/var/@key", "url")
      assert_valid_node(@document, "//user-attributes/var",      "http://www.example.com/users/1234")
    end
  end

  should "not send empty request data" do
    notice = build_notice
    assert_nil notice.url
    assert_nil notice.controller
    assert_nil notice.action
    assert_empty notice.user_attributes

    xml = notice.to_xml
    document = Nokogiri::XML.parse(xml)
    assert_nil document.at('//request/url')
    assert_nil document.at('//request/component')
    assert_nil document.at('//request/action')
    assert_nil document.at('//user-attributes')

    assert_valid_notice_document document
  end


end
