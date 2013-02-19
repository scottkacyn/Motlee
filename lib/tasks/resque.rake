require 'resque/tasks'
task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'

  Resque.after_fork do |worker|
    ActiveRecord::Base.establish_connection
  end
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
