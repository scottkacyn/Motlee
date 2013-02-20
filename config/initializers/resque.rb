Dir["/app/app/jobs/*.rb"].each { |file| require file }

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)
Resque.redis = REDIS
