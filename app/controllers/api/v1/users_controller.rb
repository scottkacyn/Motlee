class Api::V1::UsersController < ApplicationController
  
  before_filter :authenticate_user!
  respond_to :json

  def index
    @user = current_user

    if (params[:type] == "verbose")
	render :json => user.as_json({:include => [:events_attended], :methods => [:recent_photos]})
    else
    	render :json => @user.as_json(:only => [:id, :name, :first_name, :last_name, :email, :uid])
    end
  end

  def show
    if (params[:username])
      user = User.where(:username => params[:username])
    else
      user = User.find(params[:id])
    end
    if (params[:type] == "verbose")
	render :json => user.as_json({:include => [:events_attended], :methods => [:recent_photos]})
    else
    	render :json => user.as_json(:only => [:id, :name, :first_name, :last_name, :email, :uid])
    end
  end


  def friends
    users = current_user.motlee_friends(params[:access_token])
    render :json => users.as_json
  end

  def notifications
    if (params[:type].nil? or params[:type] == "unread")
        
        key = "#{params[:user_id]}:unread"
    	render :json => REDIS.lrange(key, 0, -1)
  
    elsif (params[:type] == "all")

	render :json => Notifications.get_notifications_mark_read(params[:user_id])	

    end

  end

  # api/users/<user id>/events
  # ...
  def events
	  @user = User.find(params[:id])
	  @events = User.events;
  end

  def photos
	  @user = User.find(params[:id])
  end

end
