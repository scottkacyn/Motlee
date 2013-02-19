class Api::V1::TokensController < ApplicationController
    skip_before_filter :verify_authenticity_token
    
    respond_to :json
    def create
      access_token = params[:access_token]
	
        if (access_token.blank?)
		render :json => {:mesage => "No access token was passed" }
		return
	end

      http = Curl.get("https://graph.facebook.com/app", {:access_token => access_token})
      http_response = http.body_str.to_json

	result = JSON.parse(http.body_str)
	id = result['id']

	if (id != "283790891721595")
	  render :json => {:message => "The access token passed here came from a different app. You might have Erik Nomitch trying to hack you"}
	else
	  # Now you at least know that the request came from Motlee
	  # and not some other random Facebook app
	  http = Curl.get("https://graph.facebook.com/me", {:access_token => access_token})
	  result = JSON.parse(http.body_str)
	  uid = result['id']
	  user = User.where(:uid => uid).first

	  unless user  	
	  # A Motlee entry has not yet been created. Create one now
          #
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
                               :is_activated => 't',
                               :picture => "https://graph.facebook.com/" + uid + "/picture",
                               :password => Devise.friendly_token[0,20]
                              )

	    Resque.enqueue(AddFriendJoinNotification, user.id, access_token)

	  end

          user.ensure_authentication_token!
          render :json => { :user => user.as_json, :token => user.authentication_token }
        end
    end



    def destroy
      @user=User.find_by_authentication_token(params[:id])
      if @user.nil?
        render :status=>404, :json=>{ :message=> "Invalid token."}
      else
        @user.reset_authentication_token!
        render :status=>200, :json=>{:token=>params[:id]}
      end
    end

end
