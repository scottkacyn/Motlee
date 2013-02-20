Dir["/app/jobs/*.rb"].each { |file| require file }

Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
