class Api::V1::UsersController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
    @user = current_user
    render :json => @user.to_json(:only => [:id, :name, :first_name, :last_name, :email, :uid])
  end

  def show
    @user = User.find(params[:id])
    render :json => @user.to_json(:only => [:id, :name, :first_name, :last_name, :email, :uid, :picture])
  end

end
