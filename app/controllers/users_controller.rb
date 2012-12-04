class UsersController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
  end

  def show
    if (params[:username])
      @user = User.where(:username => params[:username]).first
    else
      @user = User.find(params[:id])
    end

    @photos = @user.photos
    @events = @user.events
  end

end
