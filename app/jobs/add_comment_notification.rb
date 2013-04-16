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
			PushNotification.add_comment_notification(commentable.user_id, photo, owner_comment)
        end

		comments = Comment.where(:commentable_id => commentable_id)

		comments do |userComment|

			owner = User.find(userComment.user_id)

			if (owner_comment.id != owner.id && commentable.user_id != owner.id && userComment.id != comment.id)

				@notification_value = "#{owner_comment.name} commented on a photo you commented on|photo_comment|#{commentable.id}|#{owner.id}|#{current_date}"
            	Notifications.add_notification(commentable.user_id, @notification_value)
				PushNotification.add_comment_notification(owner.id, photo, owner_comment)
			end

		end
    end
end
