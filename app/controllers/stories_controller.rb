class StoriesController < ApplicationController
  
  before_filter :load_event_if_exists
 
  # GET /stories
  # GET /stories.xml
  def index
    @stories = @event.stories

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stories }
      format.json  { render :json => @stories.to_json(:include => [:comments, :likes]) }
    end
  end

  # GET /stories/1
  # GET /stories/1.xml
  def show
    @story = @event.stories.find(params[:id])
    @commentable = @story
    @comments = @commentable.comments
    @comment = Comment.new
    @likeable = @story
    @likes = @likeable.likes
    @like = Like.new
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @story }
      format.json  { render :json => @story.to_json(:include => [:comments, :likes]) }
    end
  end

  # GET /stories/new
  # GET /stories/new.xml
  def new
    @story = Story.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @story }
      format.json { render :json => @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
  end

  # POST /stories
  # POST /stories.xml
  def create
    @story = Story.new(params[:story])

    respond_to do |format|
      if @story.save
        @event = @story.event
        format.html { redirect_to(@event, :notice => 'Story was successfully created.') }
        format.xml  { render :xml => @story, :status => :created, :location => @event }
        format.json  { render :json => @story, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
        format.json  { render :json => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.xml
  def update
    @story = Story.find(params[:id])

    respond_to do |format|
      if @story.update_attributes(params[:story])
        format.html { redirect_to(@story, :notice => 'Story was successfully updated.') }
        format.xml  { head :ok }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
        format.json  { render :json => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.xml
  def destroy
    @story = Story.find(params[:id])
    @story.destroy

    respond_to do |format|
      format.html { redirect_to(stories_url) }
      format.xml  { head :ok }
      format.json  { head :ok }
    end
  end

private

  def load_event_if_exists
    @event = Event.find(params[:event_id])
  end
end
