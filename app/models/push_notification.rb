class PushNotification

    def self.add_event_notification(invitee_user_id, event, inviter_user)
        devices = Device.where(:user_id => invitee_user_id)
        notification_value = "#{inviter_user.name} invited you to #{event.name}"
        devices.each do |device|
            if (device.device_type == "Apple")
                PushNotification.send_to_APNS(device.device_id, notification_value)
            elsif (device.device_type == "Android")
                PushNotification.send_to_GCM(device.device_id, notification_value, inviter_user.id, event.id)
            end
        end
    end

    def self.send_to_APNS(device_id, message)
        device = APN::Device.where(:token => device_id).first_or_create 
        notification = APN::Notification.new   
        notification.device = device   
        notification.badge = 1
        notification.sound = true
        notification.alert = message
        notification.save

        rake apn:notifications:deliver
    end

    def self.send_to_GCM(device_id, message, inviter_id, event_id)
        device = Gcm::Device.where(:registration_id => "#{device_id}").first_or_create
        notification = Gcm::Notification.new
        notification.device = device
        notification.collapse_key = "new_events"
        notification.delay_while_idle = true
        notification.data = {:registration_ids => ["#{device_id}"], :data => {:message_text => message, :inviter => inviter_id, :event_id => event_id}}
        notification.save

        response = Gcm::Notification.send_notifications
    end

end
