require 'resque'

module PublishFacebookInvite

    @queue = :facebook_invite

    def self.perform(token, event_url, profile_url)

        # Scrape the two URLs so that the scraper info is up-to-date
        #
        Curl.post("https://graph.facebook.com?id=#{event_url}&scrape=true");
        Curl.post("https://graph.facebook.com?id=#{profile_url}&scrape=true");
        
        # Process the Facebook Open Graph action
        #
        Curl.post("https://graph.facebook.com/me/motleeapp:invite",
                    {:access_token => token,
                     :event => event_url,
                     :profile => profile_url})
    end

end
