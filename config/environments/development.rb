Motlee::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  
  Paperclip.options[:command_path] = "usr/bin/"

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  ENV['S3_BUCKET'] = 'motlee-staging-photos'
  ENV['S3_KEY'] = 'AKIAIZEAHVEKVBBVZAVQ'
  ENV['S3_SECRET'] = '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'
  ENV['SUPERUSER_ID'] = '1'
  ENV["REDISTOGO_URL"] = 'redis://redistogo:9918b9ce59e2deadf87b3412ad13adc2@spadefish.redistogo.com:9258/'

end
