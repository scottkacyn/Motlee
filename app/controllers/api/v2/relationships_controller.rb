class Api::V2::RelationshipsController < ApplicationController
  
  before_filter :authenticate_user!

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    render :json => @user.as_json
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    render :json => @user.as_json
  end

end
