require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'

  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
  Resque.redis = ENV['REDISTOGO_URL'] || 'redis://localhost:6379'
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

