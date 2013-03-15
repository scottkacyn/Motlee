# Override your default settings for the Development environment here.
# 
# Example:
#   configatron.file.storage = :local

configatron.apn.passphrase => 'dAl1nKx5L3NC'
configatron.apn.port => 2195
configatron.apn.host => 'gateway.sandbox.push.apple.com'
configatron.apn.cert => File.join(RAILS_ROOT, 'config', 'apple_push_notification_development.pem')

configatron.apn.feedback.passphrase => 'dAl1nKx5L3NC'
configatron.apn.feedback.port => 2196
configatron.apn.feedback.host => 'feedback.sandbox.push.apple.com'
configatron.apn.feedback.cert => File.join(RAILS_ROOT, 'config', 'apple_push_notification_development.pem')
