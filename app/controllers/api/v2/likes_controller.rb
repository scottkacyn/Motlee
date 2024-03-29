class Api::V2::LikesController < ApplicationController
  
  before_filter :load_likeable, :authenticate_user!

  respond_to :json

  def index
    @likes = @likeable.likes
    render :json => @likes.as_json
  end

  def new
    @like = @likeable.likes.new
  end


  def create
    if !@likeable.likes.where(:user_id => current_user.id).exists?
      @like = @likeable.likes.new(params[:like])
      @like.user_id = current_user.id

      if @like.save
        Resque.enqueue(AddLikeNotification, @like.id, @likeable.id)
	render :json => @like, :status => :created 
      else
	render :json => @like.errors, :status => :unprocessable_entity
      end
    else
	@like = @likeable.likes.where(:user_id => current_user.id).first
    	if @like.destroy
		render :json => @like.as_json
	else
		render :json => @like.errors, :status => :unprocessable_entity
	end
    end
  end

private
  
  def load_likeable
    klass = [Photo, Story].detect { |c| params["#{c.name.underscore}_id"] }
    @likeable = klass.find(params["#{klass.name.underscore}_id"])
  end

end
