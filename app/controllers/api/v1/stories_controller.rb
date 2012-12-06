class Api::V1::StoriesController < ApplicationController
  
  before_filter :load_event_if_exists, :authenticate_user!

  respond_to :json

  # GET /stories
  # GET /stories.xml
  def index
    @stories = @event.stories
    render :json => {:message => "poop"}
    return
    render :json => @stories.as_json(:methods => [:owner], :include => [:comments, :likes])
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
    render :json => {:message => "poop"}
    return
    
    render :json => @story.as_json(:methods => [:owner], :include => [:comments, :likes])
  end

  # GET /stories/new
  # GET /stories/new.xml
  def new
    @story = Story.new
    render :json => @story
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
  end

  # POST /stories
  # POST /stories.xml
  def create
    @story = Story.new(params[:story])
      @story.user_id = current_user.id
      @story.event_id = @event.id
      if @story.save
        @event.update_attributes(:updated_at => @story.updated_at)
        render :json => @story, :status => :created
      else
        render :json => @story.errors, :status => :unprocessable_entity
      end
  end

  # PUT /stories/1
  # PUT /stories/1.xml
  def update
    @story = Story.find(params[:id])
      if @story.update_attributes(params[:story])
        head :ok
      else
        render :json => @story.errors, :status => :unprocessable_entity
      end
  end

  # DELETE /stories/1
  # DELETE /stories/1.xml
  def destroy
    @story = Story.find(params[:id])
    @story.destroy
      head :ok
  end

private

  def load_event_if_exists
    @event = Event.find(params[:event_id])
  end
end
