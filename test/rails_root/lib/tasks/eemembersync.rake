namespace :eemembersync do
  desc "Load the sample EE data in to the test database"
  task :load_ee_data => ['eemembersync:connect', 'eemembersync:purge_db'] do
    # load the EE test data
    sql = File.read(File.join(RAILS_ROOT, 'db', 'ee_data.sql'))
    sql.split('--- split ---').each do |x|
      ActiveRecord::Base.connection.execute(x)
    end
  end

  desc "Clean the test database"
  task :purge_db do
    # drop all tables
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  desc "Establish DB connection"
  task :connect do
    ActiveRecord::Base.establish_connection(:test)
  end
end
