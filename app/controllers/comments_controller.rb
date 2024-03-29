class CommentsController < ApplicationController

  before_filter :load_commentable, :load_event

  # GET /comments
  # GET /comments.xml
  def index
    @comments = @commentable.comments

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  def show
    @comment = Comment.find(params[:id])
  end
  
  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = @commentable.comments.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = @commentable.comments.new(params[:comment])
    if @comment.save
      redirect_to [@commentable.event, @commentable], notice: "Comment added"
    else
      render :new
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(@comment, :notice => 'Comment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
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
