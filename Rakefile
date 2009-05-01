require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Run the tests'
Rake::TestTask.new(:test => ['eemembersync:prep_db']) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

namespace :eemembersync do
  desc "Prep the test database"
  task :prep_db do
    system "cd test/rails_root && rake db:load_config eemembersync:load_ee_data db:migrate RAILS_ENV=test"
  end
end