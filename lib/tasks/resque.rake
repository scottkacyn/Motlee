require 'resque/tasks'

task "resque:setup" => :environment do
4  ENV['QUEUE'] = '*'
5end
6
7desc "Alias for resque:work (To run workers on Heroku)"
8task "jobs:work" => "resque:work"

