class Api::V1::CommentsController < ApplicationController

  before_filter :load_commentable, :load_event

  respond_to :json

  # GET /comments
  def index
    @comments = @commentable.comments
    render :json => @comments
  end

  def show
    @comment = Comment.find(params[:id])
    render :json => @comment
  end
  
  # GET /comments/new
  def new
    @comment = @commentable.comments.new
  end

  # POST /comments
  def create
    @comment = @commentable.comments.new(params[:comment])
    @comment.user_id = current_user.id
    if @comment.save
      @event.update_attributes(:updated_at => @comment.updated_at)
      render :json => @comment, :status => :created
    else
      render :json => @comment.errors, :status => :unprocessable_entity
    end
  end

  # PUT /comments/1
  def update
    @comment = Comment.find(params[:id])

      if @comment.update_attributes(params[:comment])
        render :json => @comment, :status => :updated
      else
	render :json => @comment.errors, :status => :unprocessable_entity
      end
  end

  # DELETE /comments/1
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    head :ok
  end

private

#  def load_commentable
#    resource, id = request.path.split('/')[1,2]
#    @commentable = resource.singularize.classify.constantize.find(id)
#  end
 
  def load_commentable
    klass = [Photo, Story].detect { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end
  
  def load_event
    @event = Event.find(params[:event_id])
  end

end
