
if Rails.env.production?
  OmniAuth.config.full_host = "http://www.motleeapp.com"
elsif Rails.env.test?
  OmniAuth.config.full_host = "http://www.motleeapp.com"
elsif Rails.env.development?
  OmniAuth.config.full_host = "http://dev.motleeapp.com"
end
