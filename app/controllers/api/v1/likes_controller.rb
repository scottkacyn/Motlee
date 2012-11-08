class Api::V1::LikesController < ApplicationController
  
  before_filter :load_likeable

  respond_to :json

  def index
    @likes = @likeable.likes
    render :json => @likes
  end

  def new
    @like = @likeable.likes.new
  end

  def create
    if !@likeable.likes.where(:user_id => current_user.id).exists?
      @like = @likeable.likes.new(params[:like])
      if @like.save 
	render :json => @like, :status => :created 
      else
	render :json => @like.errors, :status => :unprocessable_entity
      end
    else
      render :json => "User has already liked this object."
    end
  end

private
  
  def load_likeable
    klass = [Photo, Story].detect { |c| params["#{c.name.underscore}_id"] }
    @likeable = klass.find(params["#{klass.name.underscore}_id"])
  end

end
