require 'resque'

module AddCommentNotification
    @queue = :notification

    def self.perform(comment_id, commentable_id)

        comment = Comment.find(comment_id)
        commentable = Photo.find(commentable_id)
        owner_photo = User.find(commentable.user_id)
        current_date = DateTime.now
        owner_comment = User.find(comment.user_id)
        if (commentable.user_id != owner_comment.id)	
            @notification_value = "#{owner_comment.name} commented on your photo|photo_comment|#{commentable.id}|#{owner_comment.id}|#{current_date}"
            Notifications.add_notification(commentable.user_id, @notification_value)
	    PushNotification.add_comment_notification(commentable.user_id, commentable, owner_comment)
        end

        comments = Comment.where(:commentable_id => commentable_id)

        @users_who_commented = comments.collect do |comment|
            comment.user_id
        end.uniq!

        puts @users_who_commented

        comments.each do |userComment|
            if (owner_comment.id != userComment.user_id && owner_photo.id != userComment.user_id && @users_who_commented.include?(userComent.user_id))
                @notification_value = "#{owner_comment.name} also commented on #{owner_photo.name}'s photo|photo_comment|#{commentable.id}|#{userComment.user_id}|#{current_date}"
                Notifications.add_notification(commentable.user_id, @notification_value)
                PushNotification.add_comment_notification(userComment.user_id, commentable, owner_comment)

                # Remove the ID from array of IDs so we don't send multiple notifications
                # to users on a single comment
                @users_who_commented.delete(userComment.user_id)

                puts "Removed element: " + @users_who_commented
            end
        end
    end
end
