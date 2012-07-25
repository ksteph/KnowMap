require 'rake'
require 'rubygems'
require 'rufus/scheduler'  

#load Rails.root.join('lib', 'tasks', 'tempfile.rake')
#load Rails.root.join('lib', 'tasks', 'export_data.rake')

scheduler = Rufus::Scheduler.start_new

scheduler.every("1h") do
    #Rake::Task["csv:export"].invoke
    system("rake csv:export")
end
