class Notifications < ActiveRecord::Base


	def self.add_event_notification(invitee_user_id, event, inviter_user)

		current_date = DateTime.now

		@notification_value = "#{inviter_user.name} invited you to #{event.name}:event:#{event.id}:#{inviter_user.id}:#{current_date}"

		Notifications.add_notification(invitee_user_id, @notification_value)
	end

	def self.add_event_story_notification(story, event)

		current_date = DateTime.now

		owner_user = User.where(:id => story.user_id).first

		Attendee.where("event_id = ?", params[:event_id]) do |attendee|

			@notification_value = "#{owner_user.name} posted a message in #{event.name}:event_story:#{event.id}:#{owner_user.id}:#{current_date}"

			Notifications.add_notification(attendee.user_id, @notification_value)
		end	

	end

	def self.add_comment_notification(comment, commentable)

		current_date = DateTime.now

		owner_comment = User.where(:id => comment.user_id).first	
	
		@notification_value = "#{owner_comment.name} commented on your photo:photo_comment:#{commentable.id}:#{owner_comment.id}:#{current_date}"

		Notifications.add_notification(commentable.user_id, @notification_value)

	end

	def self.add_like_notification(like, commentable)

		current_date = DateTime.now

		owner_like = User.where(:id => like.user_id).first	
	
		@notification_value = "#{owner_like.name} liked your photo:photo_comment:#{commentable.id}:#{owner_like.id}:#{current_date}"

		Notifications.add_notification(commentable.user_id, @notification_value)

	end

	def self.add_friend_join_notification(joined_user, friends)

		current_date = DateTime.now

		friends do |friend|
		
			@notification_value = "#{joined_user.name} has just joined Motlee:friend:#{joined_user.id}:#{joined_user.id}:#{current_date}"

			Notifications.add_friend_join_notifications(friend.id, @notification_value)	

		end

	end


	def self.add_notification(user_id, value)
		
		key_unread = "#{user_id}:unread"
		key_read = "#{user_id}:read"
		
		unread_count = REDIS.lpush(key_unread, value)	
		read_count = REDIS.llen(key_read)

		total_count = unread_count + read_count

		if (unread_count > 50)
			
			REDIS.rpop(key_unread)
			REDIS.del(key_read)
			
		elsif (total_count > 50)
			
			while (total_count > 50)
				REDIS.rpop(key_read)
				total_count = total_count - 1
			end
		end
	end

	def self.get_notifications_mark_read(user_id)

		key_unread = "#{user_id}:unread"
		key_read = "#{user_id}:read"

		while (REDIS.llen(key_unread) > 0)

			notification = REDIS.rpop(key_unread)
			REDIS.lpush(key_read, notification)

		end

		return REDIS.lrange(key_read, 0, -1)

	end

end
