require 'resque'

module PublishFacebookAttend

    @queue = :facebook_attend

    def self.perform(token, event_id, attendees)
        @event_url = "http://staging.motleeapp.com/events/" + event_id
        # Scrape the two URLs so that the scraper info is up-to-date
        #
        Curl.post("https://graph.facebook.com?id=#{event_url}&scrape=true");
        @fbOgAttend = FbOgAttend.where(:event_id => event_id).first
        if @fbOgAttend.nil?

            # Process the Facebook Open Graph action
            #
            json = Curl.post("https://graph.facebook.com/me/motleeapp:attend",
            {:access_token => token,
            :event => @event_url,
            "fb:explicitly_shared" => true,
            :tags => attendees})

            result = JSON.parse(json.body_str)
            newFbAttend = FbOgAttend.create(:event_id => event_id, :fb_attend_id => result["id"])
        else
            Curl.post("https://graph.facebook.com/#{@fbOgAttend.fb_attend_id}",
            {:access_token => token,
            :event => @event_url,
            "fb:explicitly_shared" => true,
            :tags => attendees})
        end
    end
end
