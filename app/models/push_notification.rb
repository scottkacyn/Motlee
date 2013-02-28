class PushNotification

    def self.add_event_notification(invitee_user_id, event, inviter_user)

		log = Logger.new(STDOUT)
		log.debug "just entered PushNotification"

		devices = Device.where(:user_id => invitee_user_id)

		notification_value = "#{inviter_user.name} invited you to #{event.name}"

		log.debug "#{inviter_user.name} invited you to #{event.name}"

		log.debug "number of devices is #{devices.count}"

		devices.each do |device|

			log.debug "Device ID: #{device.device_id}"
			log.debug "Device Type: #{device.device_type}"

			if (device.device_type == "Apple")
			
				PushNotification.send_to_APNS(device.device_id, notification_value)
		
			elsif (device.device_type == "Android")

				PushNotification.send_to_GCM(device.device_id, notification_value, inviter_user.id, event.id)

			end

		end
    end

	def self.send_to_APNS(device_id, message)
	
		#TODO: set up communication to APNS
	
	end

	def self.send_to_GCM(device_id, message, inviter_id, event_id)

		log = Logger.new(STDOUT)

		log.debug "Sending to GCM"
		log.debug "#{message}"
		log.debug "#{device_id}"

		device = Gcm::Device.where(:registration_id => "#{device_id}").first

		if (device.nil?)

			device = Gcm::Device.create(:registration_id => "#{device_id}")

		end

		log.debug "#{device.as_json}"

		notification = Gcm::Notification.new
		notification.device = device
		log.debug "Notification: #{notification.device}"
		log.debug "DeviceID: #{device.id}"
		notification.collapse_key = "new_events"
		notification.delay_while_idle = true
		notification.data = {:registration_ids => ["#{device_id}"], :data => {:message_text => message, :inviter => inviter_id, :event_id => event_id}}
		notification.save

		response = Gcm::Notification.send_notifications

		log.debug "Response: #{response.as_json}"

	end

end
