class EventsController < ApplicationController

  before_filter :authenticate_user!, :except => :show

  # GET /events
  def index
    @events = current_user.events_attended.order("updated_at DESC")
  end

  # GET /events/1
  def show
    @event = Event.find(params[:id])
    @photos = Photo.where(:event_id => @event.id).paginate(:page => params[:page], :per_page => 12)
  end

  # POST /events
  def create
    @event = Event.new(params[:event])
    @location = Location.create(:name => params[:location_name], :lat => @event.lat, :lon => @event.lon, :fsid => 0, :uid => 0)
    @event.location_id = @location.id

    respond_to do |format|
      if @event.save
        @attendee = Attendee.create(:user_id => @event.user_id, :event_id => @event.id, :rsvp_status => 1)
        format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
