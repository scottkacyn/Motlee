Dir["/app/jobs/*.rb"].each { |file| require file }

Resque.before_fork = Proc.new { 
     ActiveRecord::ActiveRecord::Base.verify_active_connections!
} 
