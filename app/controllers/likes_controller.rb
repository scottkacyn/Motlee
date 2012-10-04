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
        redirect_to @likeable, notice: "Like added"
      else
	render :new
      end
    else
      redirect_to @likeable, notice: "You've already Liked this"
    end
  end

private
  
  def load_likeable
    resource, id = request.path.split('/')[1,2]
    @likeable = resource.singularize.classify.constantize.find(id) 
  end   

end
