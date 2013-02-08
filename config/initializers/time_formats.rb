# config/initializers/time_formats.rb
#
Time::DATE_FORMATS[:pretty] = lambda { |time| time.strftime("%a, %B %e at %l:%M") + time.strftime("%p").downcase }
