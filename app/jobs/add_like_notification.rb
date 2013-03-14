require 'resque'

  module AddLikeNotification
    @queue = :notification

    def self.perform(like_id, commentable_id)

	like = Like.find(like_id)
	commentable = Photo.find(commentable_id)
        current_date = DateTime.now
        owner_like = User.where(:id => like.user_id).first
	if (commentable.user_id != owner_like.id)	
            @notification_value = "#{owner_like.name} liked your photo|photo_comment|#{commentable.id}|#{owner_like.id}|#{current_date}"
            Notifications.add_notification(commentable.user_id, @notification_value)
        end
    end
  end
