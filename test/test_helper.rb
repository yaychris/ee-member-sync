require File.join(File.dirname(__FILE__), '..', 'lib', 'ee_member_sync')

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/rails_root/config/environment")

require 'test_help'
require 'shoulda'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false


  def query(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def select_all(sql)
    ActiveRecord::Base.connection.select_all(sql)
  end
end
