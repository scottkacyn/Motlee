class Api::V2::UsersController < ApplicationController
  
  before_filter :authenticate_user!
  respond_to :json

  def index
    @user = current_user

    if (params[:type] == "verbose")
	render :json => @user.as_json({:include => [:events_attended], :methods => [:recent_photos]})
    else
    	render :json => @user.as_json(:only => [:id, :name, :first_name, :last_name, :email, :uid, :sign_in_count])
    end
  end

  def show
    if (params[:username])
      user = User.where(:username => params[:username])
    else
      user = User.find(params[:id])
    end
    if (params[:type] == "verbose")
	render :json => user.as_json({
            :include => [{:events_attended => {:methods => :attendee_count}}], 
            :methods => [:recent_photos, :following_count, :follower_count]
        })
    else
    	render :json => user.as_json(
            :only => [:id, :name, :first_name, :last_name, :email, :uid, :sign_in_count, :is_private])
    end
  end

  def follow
    user = User.find(params[:followed_id])
    if current_user.following?(user)
      current_user.unfollow!(user)
      render :json => current_user.relationships.find_by_followed_id(user.id).as_json
    else
      current_user.follow!(user)
      render :json => current_user.relationships.find_by_followed_id(user.id).as_json
    end
  end

  def approve_follower
    user = User.find(params[:follower_id])
    current_user.approve_follower!(user)
    render :json => current_user.relationships.find_by_followed_id(user.id).as_json
  end

  def reject_follower
    user = User.find(params[:follower_id])
    current_user.reject_follower!(user)
    render :json => current_user.relationships.find_by_followed_id(user.id).as_json
  end

  def following
    user = (params[:id] ? User.find(params[:id]) : current_user)
    render :json => user.followed_users.as_json
  end

  def followers
    user = (params[:id] ? User.find(params[:id]) : current_user)
    render :json => user.followers.as_json
  end

  def pending_followers
    render :json => current_user.pending_followers.as_json
  end

  def favorites
    favorites = Event.favorites_for_user(current_user)
    render :json => favorites.as_json
  end

  def notifications
    if (params[:type].nil? or params[:type] == "unread")
        key = "#{params[:id]}:unread"
    	render :json => REDIS.lrange(key, 0, -1)
    elsif (params[:type] == "all")
	render :json => Notifications.get_notifications_mark_read(params[:id])	
    end
  end

  def destroy
    render :status => :success
    #auth_token = params[:auth_token]
    #if (auth_token == current_user.authentication_token)
    #    current_user.destroy
    #    render :json => current_user.as_json
    #else
    #    render :status => :forbidden
    #end
  end

  # POST 
  # api/users/<user id>/device
  def device
    device = Device.where(:user_id => current_user.id, :device_id => params[:device_id], :device_type => params[:type]).first_or_create
    render :json => device.as_json
  end

  # PUT
  # api/users/<id>/update_privacy
  def update_privacy
    current_user.is_private = params[:is_private]
    current_user.save
    render :json => current_user.as_json
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
