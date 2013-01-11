require 'resque'


  module AddFriendJoinNotification
    @queue = :notification

    def self.perform(joined_user_id, access_token)
	joined_user = User.find(joined_user_id)
	friends = joined_user.motlee_friends(access_token)
        current_date = DateTime.now
        friends.each do |friend|
            @notification_value = "Your friend #{joined_user.name} has just joined Motlee|friend|#{joined_user.id}|#{joined_user.id}|#{current_date}"
            Notifications.add_notification(friend.id, @notification_value)	
        end
    end
  end
