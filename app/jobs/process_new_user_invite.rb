require 'resque'

module ProcessNewUserInvite

    @queue = :invitations

    def self.perform(access_token, event_id, uid)

        http = Curl.get("https://graph.facebook.com/" + uid)
        result = JSON.parse(http.body_str)
        
        email = ''
        if result['email'].nil?
          if result['username'].nil?
            email = uid + "@facebook.com"
          else
            email = result['username'] + "@facebook.com"
          end
        else
          email = result['email']
        end

        gender = ''
        if result['gender'].nil?
          gender = 'unknown'
        else
          gender = result['gender']
        end

        birthday = ''
        if result['birthday'].nil?
          birthday = 'unknown'
        else
          birthday = result['birthday']
        end

        username = ''
        if result['username'].nil?
          username = 'unknown'
        else
          username = result['username']
        end
        user = User.create(:name => result['name'],
                           :provider => "facebook",
                           :uid => result['id'],
                           :email => email,
                           :first_name => result['first_name'],
                           :last_name => result['last_name'],
                           :birthday => birthday,
                           :username => username,
                           :gender => gender,
                           :picture => "https://graph.facebook.com/" + uid + "/picture",
                           :password => Devise.friendly_token[0,20]
                          )
        @attendee = Attendee.create(:user_id => user.id, :event_id => event_id, :rsvp_status => 1)

        event_url = "http://www.motleeapp.com/events/" + event_id
        profile_url = "http://www.motleeapp.com/users/" + user.id.to_s

        # Scrape the two URLs so that the scraper info is up-to-date
        #
        Curl.post("https://graph.facebook.com?id=#{event_url}&scrape=true");
        Curl.post("https://graph.facebook.com?id=#{profile_url}&scrape=true");
        
        # Process the Facebook Open Graph action
        #
        Curl.post("https://graph.facebook.com/me/motleeapp:invite",
                    {:access_token => access_token,
                     :event => event_url,
                     :profile => profile_url})
    end
end
