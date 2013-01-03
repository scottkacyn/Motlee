require 'resque'


  module AddCommentNotification
    @queue = :notification

    def self.perform(comment_id, commentable_id)

	comment = Comment.find(comment_id)
	commentable = Photo.find(commentable_id)
        current_date = DateTime.now
        owner_comment = User.where(:id => comment.user_id).first
        if (commentable.user_id != owner_comment.id)	
            @notification_value = "#{owner_comment.name} commented on your photo|photo_comment|#{commentable.id}|#{owner_comment.id}|#{current_date}"
            Notifications.add_notification(commentable.user_id, @notification_value)
	end
    end
  end
