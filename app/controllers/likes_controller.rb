class LikesController < ApplicationController
  
  before_filter :load_likeable

  def index
    @likes = @likeable.likes
  end

  def new
    @like = @likeable.likes.new
  end

  def create
    if !@likeable.likes.where(:user_id => current_user.id).exists?
      @like = @likeable.likes.new(params[:like])
      if @like.save  
        redirect_to "/", notice: "Like added"
      else
	render :new
      end
    else
      redirect_to [@likeable.event, @likeable], notice: "You've already Liked this"
    end
  end

private
  
  def load_likeable
    klass = [Photo, Story].detect { |c| params["#{c.name.underscore}_id"] }
    @likeable = klass.find(params["#{klass.name.underscore}_id"])
  end

end
