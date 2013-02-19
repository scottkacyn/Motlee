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
                           :is_activated => 'f',
                           :picture => "https://graph.facebook.com/" + uid + "/picture",
                           :password => Devise.friendly_token[0,20]
                          )
        @attendee = Attendee.create(:user_id => user.id, :event_id => event_id, :rsvp_status => 1)
    end
end
