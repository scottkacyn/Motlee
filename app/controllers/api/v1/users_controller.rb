class Api::V1::UsersController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
    @user = current_user

    if (params[:type] == "verbose")
	render :json => @user.as_json({:include => [:photos, :events_attended, :events_fomoed, :likes, :comments, :stories]})
    else
    	render :json => @user.as_json(:only => [:id, :name, :first_name, :last_name, :email, :uid])
    end
  end

  def show
    @user = User.find(params[:id])
    render :json => @user.as_json(:only => [:id, :name, :first_name, :last_name, :email, :uid, :picture])
  end

  def friends
    users = current_user.motlee_friends(params[:access_token])
    render :json => users.as_json
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
