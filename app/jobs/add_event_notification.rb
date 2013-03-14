require 'resque'

  module AddEventNotification
    @queue = :notification

    def self.perform(invitee_user_id, event_id, inviter_user_id)
	event = Event.find(event_id)
	inviter_user = User.find(inviter_user_id)
        current_date = DateTime.now
        @notification_value = "#{inviter_user.name} invited you to #{event.name}|event|#{event.id}|#{inviter_user.id}|#{current_date}"
        Notifications.add_notification(invitee_user_id, @notification_value)
        PushNotification.add_event_notification(invitee_user_id, event, inviter_user)
    end
  end

