require 'rake'
require 'rake/testtask'
require 'bundler/gem_helper'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the airbrake_user_attributes gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

Bundler::GemHelper.install_tasks

