require 'resque'

  module AddFavoriteNotification
    @queue = :favorite

    def self.perform(favorite_user_id, event_id)
	favorite_user = User.find(favorite_user_id)
	event = Event.find(event_id)

	if (event.user_id != favorite_user_id)

		@message = "#{favorite_user.name} favorited your stream,  #{event.name}!"
		@notification_value = @message + "|event_favorite|#{event_id}|#{favorite_user_id}|#{current_date}"
		Notifications.add_notification(event.user_id, @notification_value)
		PushNotification.add_favorite_notification(event.user_id, favorite_user_id, event_id, @message)
	end
  end
