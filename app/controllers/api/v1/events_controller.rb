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

  def join
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
		      # User successfully added to event
		    else
		      # Something went wrong
		    end
	    else
	      # User has already been added to the event
	    end
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
