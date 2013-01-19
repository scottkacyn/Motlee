require 'resque'

module PublishFacebookAttend

    @queue = :facebook_attend

    def self.perform(token, event_id, attendees)

		event_url = "http://www.motleeapp.com/events/" + event_id

		# Scrape the two URLs so that the scraper info is up-to-date
		#
		Curl.post("https://graph.facebook.com?id=#{event_url}&scrape=true");
		
		#Double check this, Scott, I think this is rigth
		fbOgAttend = FbOgAttend.where(:event_id => event_id)

		if fbOgAttend.nil?

			# Process the Facebook Open Graph action
			#
			json = Curl.post("https://graph.facebook.com/me/motleeapp:attend",
					    {:access_token => token,
					     :event => event_url,
					     :fb:explicitly_shared => true,
						 :tags => attendees})

			parsed_json = ActiveSupport::JSON.decode(json)

			newFbAttend = FbOgAttend.new(:event_id => event_id, :fb_attend_id => parsed_json["id"])

			newFbAttend.save

		else

			Curl.post("https://graph.facebook.com/#{fbOgAttend.fb_attend_id}",
				    {:access_token => token,
				     :event => event_url,
				     :fb:explicitly_shared => true,
					 :tags => attendees})

		end

	

    end

end
