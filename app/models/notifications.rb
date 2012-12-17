class Notifications < ActiveRecord::Base

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
