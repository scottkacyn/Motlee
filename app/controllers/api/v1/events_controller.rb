class Api::V1::EventsController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  # GET
  # /api/events
  # Returns a list of ALL the users events and events she is attending
  def index
	  fbuid = current_user.uid
	  access_token = params[:access_token]
	  @friends ||= Array.new
	  @friends << current_user.id

	  http = Curl.get("https://graph.facebook.com/me/friends", {:access_token => access_token})
	  result = JSON.parse(http.body_str)

	  result.each do |key,value|
	  	if key == "data"
			value.each do |str|
				@user = User.where(:uid => str['id']).first
				if (!@user.nil?)
					@friends << @user.id
				end
			end
		end
	  end

	  @events = Event.joins(:attendees).where(:attendees => {:user_id => @friends})
	  render :json => @events.as_json(:methods => [:owner, :fomo_count, :attendee_count, :is_attending])
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
	    :event => @event.as_json({root: false, :methods => [:owner, :fomo_count, :attendee_count], :include => [:photos, :stories, :people_attending, :fomoers] }) }
   
  end

  # POST
  # /api/events
  def create
    @event = Event.new(params[:event])
 
    if (@event.name.blank?)
      render :json => {:message => "The event name was NULL, not saving"}
      return
    end
    if @event.save
	@attendee = Attendee.new(:user_id => current_user.id, :event_id => @event.id, :rsvp_status => 1)
	if @attendee.save
		# Success
	else
		# Failure
	end
    	render :json => @event, :status => :created
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

	    @uid_array.each do |uid|
	      motlee_user = User.where(:uid => uid).first
	      if (motlee_user.nil?) #User is not currently a Motlee user
		# We're going to add the user to Motlee as a "placeholder"
	      else
		# User is a Motlee user, let's check to make sure he or she hasn't already been added to the event
		    # TODO - Add validation to this model and call first_or_initialize! instead of ...initialize 
		    # TODO = Upgrade to Rails 3.2.1 so that you can use the above method
		    #@attendee = Attendee.where("user_id = ? AND event_id = ?", @user_id, @event_id).first_or_initialize(:user_id => @user_id, :event_id => @event_id, :rsvp_status => 1)
		   
		    @attendee = Attendee.where("user_id = ? AND event_id = ?", motlee_user.id, params[:event_id]).first

		    if (@attendee.nil?)
		      @attendee = Attendee.new(:user_id => motlee_user.id, :event_id => params[:event_id], :rsvp_status => 1)
		    end

		    if @attendee.new_record? 
			    if @attendee.save
			      render :json => {:success => "User added as attendee successfully"}
			    else
			      render :json => {:error => "Something went wrong"}
			    end
		    else
		      # User has already been added to the event
		    end
	      end
	    end
    else
	    @attendee = Attendee.where("user_id = ? AND event_id = ?", current_user.id, params[:event_id]).first

	    if (@attendee.nil?)
	      @attendee = Attendee.new(:user_id => current_user.id, :event_id => params[:event_id], :rsvp_status => 1)
	    end

	    if @attendee.new_record? 
		    if @attendee.save
		      # User successfully added to event
		    else
		      # Something went wrong
		    end
	    else
	      # User has already been added to the event
	    end
    end
    render :json => {:message => "We just did stuff!"}
  end

  def update
    respond_with Event.update(params[:id], params[:events])
  end

  def destroy
    respond_with Event.destroy(params[:id])
  end

end
