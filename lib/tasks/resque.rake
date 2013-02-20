require 'resque/tasks'

puts "lib/tasks/resque.rb"

task "resque:setup" => :environment do
    ENV['QUEUE'] = '*'

    if ENV['NEW_RELIC_APP_NAME']
        NewRelic::Agent.manual_start :app_name => ENV['NEW_RELIC_APP_NAME']
    end
    Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
    Resque.redis = ENV['REDISTOGO_URL']
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
