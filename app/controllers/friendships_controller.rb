class FriendshipsController < ApplicationController

  before_filter :authenticate_user!
  
  # POST /friendships
  # POST /friendships.json
  def create
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    if @friendship.save
        render :json => @friendship, :status => :created
    else
        render :json => @friendship.errors, :status => :unprocessable_entity
    end
  end

  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy
    @friendship = current_user.friendships.find(params[:id])
    @friendship.destroy
    render :json => @friendship
  end

end
