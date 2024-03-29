require 'resque'

module PublishFacebookJoin
    @queue = :facebook

    def self.perform(access_token, url)
        Curl.post("https://graph.facebook.com?id=#{url}&scrape=true")

        Curl.post("https://graph.facebook.com/me/motleeapp:join", {:access_token => access_token, :event => url})
    end
end
