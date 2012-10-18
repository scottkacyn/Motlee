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
      #http_response = http.body_str.to_json
       
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
	  email = result['email']

	  @user = User.where(:uid => uid).first

	  if @user.nil?
	    # A Motlee entry has not yet been created. Create one now
	      render :status => 200, :json => {:message => "A user has not yet been invited to the party that is Motlee!"}
	  else
	    # A Motlee user has already been created, return his goodies
	      # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
	      @user.ensure_authentication_token!
	      render :json => { :token => @user.authentication_token }
	  end
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
