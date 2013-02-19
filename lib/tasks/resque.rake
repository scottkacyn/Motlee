require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'

  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  Resque.redis = REDIS
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

