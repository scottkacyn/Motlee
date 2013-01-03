require 'resque'


  module AddEventStoryNotification
    @queue = :notification

    def self.perform(story_id, event_id)

        story = Story.find(story_id)
        event = Event.find(event_id)
        current_date = DateTime.now
        owner_user = User.where(:id => story.user_id).first
        attendees = Attendee.where(:event_id => event.id)
        attendees.each do |attendee|
	    if (attendee.user_id != owner_user.id)
                notification_value = "#{owner_user.name} posted a message in #{event.name}|event_story|#{event.id}|#{owner_user.id}|#{current_date}"
                Notifications.add_notification(attendee.user_id, notification_value)
	    end
        end
     end
  end
