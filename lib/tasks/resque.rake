require 'resque/tasks'
task "resque:setup" => :environment do
    ENV['QUEUE'] = '*'

    Resque.before_fork = Proc.new { 
         ActiveRecord::Base.verify_active_connections!
    } 
    
    Resque.after_fork do
        defined?(ActiveRecord::Base) and
        ActiveRecord::Base.establish_connection
        puts "Resque connection ESTABLISHED"
    end
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
