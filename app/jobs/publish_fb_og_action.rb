require 'resque'

module PublishFbOgAction
    @queue = :facebook

    def self.perform(access_token, url, type)
        Curl.post("https://graph.facebook.com?id=#{url}&scrape=true")
        Curl.post("https://graph.facebook.com/me/motleeapp:#{type}", {:access_token => access_token, :event => url})
    end
end
