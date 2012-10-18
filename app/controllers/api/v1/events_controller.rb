class Api::V1::EventsController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
    @events = Event.order("created_at DESC").limit(5)
    respond_with @events.to_json(:include => [:photos, :stories, :fomos]) 
  end

  def show
    @event = Event.find(params[:id])
    respond_with @event.to_json(:include => [:photos, :stories, :fomos])
  end

  def create
    respond_with Event.create(params[:event])
  end

  def update
    respond_with Event.update(params[:id], params[:events])
  end

  def destroy
    respond_with Event.destroy(params[:id])
  end

end
