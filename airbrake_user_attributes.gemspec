# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'airbrake_user_attributes/version'

Gem::Specification.new do |s|
  s.name = 'airbrake_user_attributes'
  s.authors = ['Nathan Broadbent']
  s.email = 'nathan.f77@gmail.com'
  s.homepage = 'http://cloudfuji.com'
  s.summary = 'Send Airbrake notifications with user attributes'
  s.description = 'Adds information about the current user to error reports'
  s.files = `git ls-files`.split("\n")
  s.version = AirbrakeUserAttributes::VERSION

  s.add_development_dependency("actionpack",    "~> 2.3.8")
  s.add_development_dependency("activerecord",  "~> 2.3.8")
  s.add_development_dependency("activesupport", "~> 2.3.8")
  s.add_development_dependency("bourne",        ">= 1.0")
  s.add_development_dependency("fakeweb",       "~> 1.3.0")
  s.add_development_dependency("nokogiri",      "~> 1.4.3.1")
  s.add_development_dependency("rspec",         "~> 2.6.0")
  s.add_development_dependency("sham_rack",     "~> 1.3.0")
  s.add_development_dependency("shoulda",       "~> 2.11.3")

  s.add_dependency 'airbrake',                  '~> 3.1.0'

end
