require 'resque'

module PublishFacebookPhoto

    @queue = :facebook_photo

    def self.perform(token, photo_id)
		photo = Photo.find(photo_id)
        @link = "https://www.motleeapp.com/events/" + photo.event_id + "/photos/" + photo.id
		@photo_url = "http://s3.amazonaws.com/motlee-production-photos/images/" + photo.id + "/original/" + photo.image_file_name
        # Scrape the two URLs so that the scraper info is up-to-date
        Curl.post("https://graph.facebook.com/me/feed",
			{:message => photo.caption,
			:link => @link,
			:picture => @photo_url,
			:description => "Click here to see more on Motlee!",
			:access_token => token })
    end
end
