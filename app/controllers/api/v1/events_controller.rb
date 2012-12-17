class Api::V1::EventsController < ApplicationController
  
  before_filter :authenticate_user!
  respond_to :json

  # GET
  # /api/events
  # Returns a list of ALL the users events and events she is attending
  def index
    lat, lon = params[:lat], params[:lon]
    events = current_user.all_events(params[:access_token], (params[:updatedAfter] ? params[:updatedAfter] : "2000-01-01T00:00:00.000Z"))
    if lat and lon
        events = events.nearby(lat.to_f, lon.to_f)
    end
    render :json => events.as_json(:include => [:location, :photos, :stories, :people_attending], :methods => [:owner, :attendee_count, :is_attending])
  end

  def fb_friends
    render :json => events.as_json
  end
  
  # GET
  # /api/events/:id
  # Returns the details for the event with id = :id
  def show
    @event = Event.find(params[:id])
    is_attending = TRUE
    @attendee = Attendee.where(:user_id => current_user.id, :event_id => @event.id).first
    if @attendee.nil?
        is_attending = FALSE
    end
    
    render :json => { :is_attending => is_attending,
	              :event => @event.as_json({:methods => [:owner, :attendee_count], 
				                :include => {:photos => {:include => {:comments => {}, :likes => {}}}, 
					     	             :stories => {}, 
				     		             :people_attending => {}}})}
   
  end

  def get_event_location(location)

    #TODO FIXME
    # If users try to create a location with similar names that are in the same general
    # geographic region, don't let them save a brand new object.

    uid = location['uid']
   
    if uid.nil?
      # User is creating a custom location, not based on Facebook Places
      # TODO This currently does not allow user to choose from our custom
      # locations db in the app, requires user to create from Facebook or a
      # one-off custom location.
      # location = Location.new(params[:location])
    else
      # User has either selected from FB or addinga  new FB
      location = Location.where(:uid => uid).first
      if !location.nil?
        location
        # Location with that UID already exists in the DB
	return
      end
    end
    
    location = Location.new(params[:location])
    location.save
    location
  end

  # POST
  # /api/events
  def create

    location = get_event_location(params[:location])

    @event = Event.new(params[:event])
    if (@event.name.blank?)
      render :json => {:message => "The event name was NULL, not saving"}
      return
    end
    @event.user_id = current_user.id
    if !location.nil?
    	@event.location_id = location.id
    else
	@event.location_id = 0
    end
    if @event.save
	@attendee = Attendee.new(:user_id => current_user.id, :event_id => @event.id, :rsvp_status => 1)
	if @attendee.save
		# Success
	else
		# Failure
	end
    	render :json => @event.as_json(:include => :location), :status => :created
    else
     	render :json => @event.errors, :status => :unprocessable_entity
    end
  end

  # POST
  # /api/events/:id/join
  # Allows you to add a user to an event as an attendee
  # Requires :uids param which is an array of Facebook UIDs
  def join
    if (params[:type] == "invite")
	    @uids = params[:uids]
	    @uid_array = []
	    @uid_array = @uids.split(",")
	    
            @motlee_users = []
            @non_motlee_users = []

            event = Event.where(:id => params[:event_id]).first

            current_date = DateTime.now

	    @uid_array.each do |uid|
	    	motlee_user = User.where(:uid => uid).first
	      	if (motlee_user.nil?) #User is not currently a Motlee user
			# We're going to add the user to Motlee as a "placeholder"
                        @non_motlee_users << motlee_user.uid
	      	else
			# User is a Motlee user, let's check to make sure he or she hasn't already been added to the event
		    	# TODO - Add validation to this model and call first_or_initialize! instead of ...initialize 
		    	# TODO = Upgrade to Rails 3.2.1 so that you can use the above method
		    	#@attendee = Attendee.where("user_id = ? AND event_id = ?", @user_id, @event_id).first_or_initialize(:user_id => @user_id, :event_id => @event_id, :rsvp_status => 1)
		   
		    	@attendee = Attendee.where("user_id = ? AND event_id = ?", motlee_user.id, params[:event_id]).first

                        @notification_value = "#{motlee_user.name} invited you to #{event.name}:event:#{params[:event_id]}:#{motlee_user.id}:#{current_date}"

                        Notifications.add_notification(motlee_user.id, @notification_value)

		    	if (@attendee.nil?)
		      		@attendee = Attendee.new(:user_id => motlee_user.id, :event_id => params[:event_id], :rsvp_status => 1)
		    	end

		    	if @attendee.new_record? 
			    	if @attendee.save
			    	else
			      		render :json => @attendee.errors, :status => :unprocessable_entity
					return
			    	end
		    	else
		      		# User has already been added to the event
		   	end
	      	end
	    end

	    render :json => {:message => "Attendees were successfully added to the event"}
    else
	    @attendee = Attendee.where("user_id = ? AND event_id = ?", current_user.id, params[:event_id]).first

	    if (@attendee.nil?)
	      @attendee = Attendee.new(:user_id => current_user.id, :event_id => params[:event_id], :rsvp_status => 1)
	    end

	    if @attendee.new_record? 
		    if @attendee.save
		      # User successfully added to event
	    	      render :json => @attendee.as_json
		    else
		      # Something went wrong
		    end
	    else
	      # User has already been added to the event
	      render :json => @attendee.as_json
	    end
    end
  end

  def update
    @event = Event.update(params[:id], params[:event])
    render :json => @event
  end

  def destroy
    respond_with Event.destroy(params[:id])
  end

end
