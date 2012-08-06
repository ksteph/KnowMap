database = Rails.configuration.database_configuration[Rails.env]["database"]
username = Rails.configuration.database_configuration[Rails.env]["username"]
password = Rails.configuration.database_configuration[Rails.env]["password"]

namespace :pg do
  
  #rake pg:dump
  desc "dumps the database to a sql file"
  task :dump, [:dumpfile] => :environment do |t,args|
    args.with_defaults(dumpfile: "db/pg_dumps/#{database}_dump_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.sql")
    puts "Creating #{database}_dump.sql file."
    `export PGPASSWORD="#{password}"; pg_dump --host localhost --username "#{username}" "#{database}" > "#{args.dumpfile}"; export PGPASSWORD=`
  end

  #rake pg:dumpimport - Resets the DB.
  desc "imports the #{database}_dump.sql file to the current db"
  task :dumpimport, [:dumpfile] => :environment do |t,args|
    args.with_defaults(dumpfile: "db/pg_dumps/#{database}_dump_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.sql")
    `export PGPASSWORD="#{password}"; psql --host localhost --username "#{username}" "#{database}" < "#{args.dumpfile}"; export PGPASSWORD=`
  end

end
