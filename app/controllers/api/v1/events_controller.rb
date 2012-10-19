class Api::V1::EventsController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
    if (params[:page] && (params[:page] == "me"))
      @events = Event.where("user_id = ?", current_user.id).order("created_at DESC")
    else
      @events = Event.order("created_at DESC")
    end
    respond_with @events.to_json(:include => [:photos, :stories, :fomos]) 
  end

  def show
    @event = Event.find(params[:id])
    respond_with @event.to_json(:include => [:photos, :stories, :fomos])
  end

  def create
    @event = Event.new(params[:event])
 
    if (@event.name.blank?)
      render :json => {:message => "The event name was NULL, not saving"}
      return
    end
    if @event.save
	respond_with @event
    else
     	render :json => {:message => "Something went wrong, event not saved"}
    end
  end

  def update
    respond_with Event.update(params[:id], params[:events])
  end

  def destroy
    respond_with Event.destroy(params[:id])
  end

end
