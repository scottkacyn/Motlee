require 'resque/tasks'

puts "lib/tasks/resque.rb"

task "resque:setup" => :environment do
    ENV['QUEUE'] = '*'
    
    Resque.before_fork do
        defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
        puts "Resque connection DISCONNECTED"
    end
    
    Resque.after_fork do
        defined?(ActiveRecord::Base) and
        ActiveRecord::Base.establish_connection
        puts "Resque connection ESTABLISHED"
    end
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
