Dir["/app/jobs/*.rb"].each { |file| require file }

Resque.after_fork do
    defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
