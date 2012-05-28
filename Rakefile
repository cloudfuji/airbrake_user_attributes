require 'rake'
require 'rake/testtask'
require 'rubygems/package_task'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the airbrake_user_attributes gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
