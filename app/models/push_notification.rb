class PushNotification

    def self.add_event_notification(invitee_user_id, event, inviter_user)
        devices = Device.where(:user_id => invitee_user_id)
        notification_value = "#{inviter_user.name} invited you to #{event.name}"
        devices.each do |device|
            if (device.device_type == "Apple")
                PushNotification.send_to_APNS(device.device_id, notification_value)
            elsif (device.device_type == "Android")
                PushNotification.send_invite_to_GCM(device.device_id, notification_value, inviter_user.id, event.id)
            end
        end
    end

    def self.add_comment_notification(comment_user_id, photo, commenter_user)
        devices = Device.where(:user_id => comment_user_id)
        notification_value = "#{commenter_user.name} commented on your photo"
        devices.each do |device|
            if (device.device_type == "Apple")
                PushNotification.send_to_APNS(device.device_id, notification_value)
            elsif (device.device_type == "Android")
                PushNotification.send_comment_like_to_GCM(device.device_id, notification_value, commenter_user.id, photo.id)
            end
        end
    end

    def self.add_like_notification(like_user_id, photo, liker_user)
        devices = Device.where(:user_id => like_user_id)
        notification_value = "#{liker_user.name} liked your photo"
        devices.each do |device|
            if (device.device_type == "Apple")
                PushNotification.send_to_APNS(device.device_id, notification_value)
            elsif (device.device_type == "Android")
                PushNotification.send_comment_like_to_GCM(device.device_id, notification_value, liker_user.id, photo.id)
            end
        end
    end

    def self.add_comment_on_comment_notification(comment_user_id, photo, commenter_user)
        devices = Device.where(:user_id => comment_user_id)
        photo_taker = User.find(photo.user_id)
        notification_value = "#{commenter_user.name} also commented on #{photo_taker.name}'s photo"
        devices.each do |device|
            if (device.device_type == "Apple")
                PushNotification.send_to_APNS(device.device_id, notification_value)
            elsif (device.device_type == "Android")
                PushNotification.send_comment_like_to_GCM(device.device_id, notification_value, commenter_user.id, photo.id)
            end
        end
    end

    def self.send_to_APNS(device_id, message)
        notification = {
            :device_tokens => [device_id],
            :aps => {:alert => message, :badge => 1, :sound => 'default'}
        }

        Urbanairship.push(notification)
    end

    def self.send_invite_to_GCM(device_id, message, inviter_id, event_id)
        device = Gcm::Device.where(:registration_id => "#{device_id}").first_or_create
        notification = Gcm::Notification.new
        notification.device = device
        notification.collapse_key = "new_events"
        notification.delay_while_idle = true
        notification.data = {:registration_ids => ["#{device_id}"], :data => {:message_text => message, :inviter => inviter_id, :event_id => event_id}}
        notification.save

        response = Gcm::Notification.send_notifications
    end

    def self.send_comment_like_to_GCM(device_id, message, commenter_id, photo_id)
        device = Gcm::Device.where(:registration_id => "#{device_id}").first_or_create
        notification = Gcm::Notification.new
        notification.device = device
        notification.collapse_key = "new_comments_likes"
        notification.delay_while_idle = true
        notification.data = {:registration_ids => ["#{device_id}"], :data => {:message_text => message, :user_id => commenter_id, :photo_id => photo_id}}
        notification.save

        response = Gcm::Notification.send_notifications
    end

end
