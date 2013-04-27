require 'resque'


  module AddFollowNotification
    @queue = :notification

    def self.perform(follower_user_id, following_user_id)
	follower_user = User.find(follower_user_id)
	following_user = User.find(following_user_id)

	if (following_user.is_private)

		@message = "#{follower_user.name} requested to follow you."
	
	else

		@message = "#{follower_user.name} started following you!"

	end

	@notification_value = @message + "|follow_request|#{follower_user_id}|#{follower_user_id}|#{current_date}"
	Notifications.add_notification(following_user_id, @notification_value}
	PushNotification.add_follow_notification(following_user_id, @message)
  end
