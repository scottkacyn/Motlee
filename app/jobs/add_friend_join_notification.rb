require 'resque'


  module AddFriendJoinNotification
    @queue = :notification

    def self.perform(joined_user_id, access_token)
	joined_user = User.find(joined_user_id)
	friends = joined_user.motlee_friends(access_token)
        current_date = DateTime.now
        friends.each do |friend|
			@message = "Your friend #{joined_user.name} has just joined Motlee"
            @notification_value = @message + "|friend|#{joined_user.id}|#{joined_user.id}|#{current_date}"
            Notifications.add_notification(friend.id, @notification_value)	
			PushNotification.add_friend_join_notification(friend.id, joined_user_id, @message)
        end
    end
  end
