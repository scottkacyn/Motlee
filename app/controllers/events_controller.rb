class EventsController < ApplicationController

  before_filter :ensure_admin_routing

  # GET /events
  def index
    #@events = Event.order("created_at DESC")
    @events = Event.where("user_id > 0").order("updated_at DESC")
  end

  # GET /events/1
  def show
    @event = Event.find(params[:id])
    @owner = User.find(@event.user_id)

    @photos = @event.photos
    @stories = @event.stories
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
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

  # PUT /events/1
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /events/1
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
    end
  end

private

  def ensure_admin_routing
    (current_user.nil?) ? redirect_to(root_path) : (redirect_to(root_path) unless (current_user.id < 4))
  end
    
end
