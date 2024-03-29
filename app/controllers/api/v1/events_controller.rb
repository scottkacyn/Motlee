class Api::V1::EventsController < ApplicationController
  
    before_filter :authenticate_user!
    respond_to :json

    # GET
    # /api/events
    def index
        events = current_user.all_events(params[:access_token], (params[:updatedAfter] ? params[:updatedAfter] : "2000-01-01T00:00:00.000Z"), (params[:paging] ? true : false))
        lat, lon = params[:lat], params[:lon]
        if lat and lon
            events = events.nearby(lat.to_f, lon.to_f)
        end
        render :json => events.as_json(:include => {:location => {}, :photos => {:methods => :owner}, :people_attending => {:only => [:id, :uid, :name, :first_name, :last_name, :picture, :birthday, :created_at, :updated_at, :sign_in_count]}})
    end

    # GET
    # /api/events/:id
    def show
        @event = Event.find(params[:id])
        @photos = @event.photos
        @attendee = Attendee.where(:user_id => current_user.id, :event_id => @event.id).first
    
        is_attending = TRUE
        if @attendee.nil?
            is_attending = FALSE
        end

        render :json => { :is_attending => is_attending,
                          :event => @event.as_json({:methods => [:owner, :attendee_count], 
                          :include => {:photos => {:include => {:comments => {:methods => [:owner]}, :likes => {:methods => [:owner]}}, :methods => :owner}, 
                          :people_attending => {:only => [:id, :uid, :name, :first_name, :last_name, :sign_in_count]}}})}
    end
    
    # POST
    # /api/events
    def create
        @event = Event.new(params[:event]) 
        @event.user_id = current_user.id
        if (@event.name.blank?)
            return
        end
        @event.is_deleted = false 
        location = Location.find_or_create_with_params(params[:location])
        @event.location_id = (location.nil?) ? 0 : location.id;
        
        if @event.save
            @attendee = Attendee.create(:user_id => current_user.id, :event_id => @event.id, :rsvp_status => 1)
            render :json => @event.as_json(:include => :location), :status => :created
        else
            render :json => @event.errors, :status => :unprocessable_entity
        end
    end

    # POST
    # /api/events/:id/unjoin
    def unjoin
        event = Event.find(params[:id])
        # User is the event creator, has delete priveleges
        mids = params[:ids]
        mid_array = []
        mid_array = mids.split(",")
        mid_array.each do |mid|
            unless (current_user.id == mid)
                @attendee = Attendee.where("user_id = ? AND event_id = ?", mid, params[:id])
                Attendee.destroy(@attendee)
            end
        end
        event.update_attributes(:updated_at => Time.now)
        render :json => event.as_json({:methods => [:owner, :attendee_count], 
           :include => {:photos => {:include => {:comments => {}, :likes => {}}}, 
           :people_attending => {:only => [:id, :uid, :name, :first_name, :last_name, :sign_in_count]}}})
    end

    # POST
    # /api/events/:id/join
    # Allows you to add a user to an event as an attendee
    # Requires :uids param which is an array of Facebook UIDs
    def join
        @event = Event.find(params[:id])
        if (params[:type] == "invite")
            @uids = params[:uids]
            @uid_array = []
            @uid_array = @uids.split(",")

            @motlee_users = []
            @non_motlee_users = []

            @uid_array.each do |uid|
                motlee_user = User.where(:uid => uid).first

                if motlee_user.nil?
                    token = params[:access_token]
                    event_id = params[:id]
                    Resque.enqueue(ProcessNewUserInvite, token, event_id, uid) 
                else
                    # User is already a part of Motlee
                    # Add user to array of Motlee users
                    @motlee_users << uid
                
                    # Now we check to see if the user has already been added to the event
                    @attendee = Attendee.where("user_id = ? AND event_id = ?", motlee_user.id, params[:id]).first
                    if @attendee.nil?
                        # If user has not been added, create new Attendee object
                        @attendee = Attendee.create(:user_id => motlee_user.id, :event_id => params[:id], :rsvp_status => 1)
                        if (motlee_user.id != current_user.id)
                            Resque.enqueue(AddEventNotification, motlee_user.id, params[:id], current_user.id)
                        end
                    end
                end
            end    
        else
            @attendee = Attendee.create(:user_id => current_user.id, :event_id => @event.id, :rsvp_status => 1)
        end
        # Render a response so the devices are happy
        @event.update_attributes(:updated_at => Time.now)
        render :json => @event.as_json({:methods => [:owner, :attendee_count], 
               :include => {:photos => {:include => {:comments => {}, :likes => {}}}, 
               :people_attending => {:only => [:id, :uid, :name, :sign_in_count]}}})
    end

    def share 
        @event = Event.find(params[:id])
        uids = ""
        for attendee in @event.attendees
            uids = uids + attendee.user.uid.to_s + ","
        end
        Resque.enqueue(PublishFacebookAttend, params[:access_token], params[:id], uids)
        render :json => @event.as_json
    end

    def update
        @event = current_user.events.update(params[:id], params[:event])

        if params[:location]
            location = Location.find_or_create_with_params(params[:location])
            if !location.nil?
                @event.update_attributes(:location_id => location.id)
            else
                @event.location_id = 0
            end
        end

        render :json => @event.as_json(:include => :location)
    end

    def destroy
        @event = current_user.events.find(params[:id])
        @event.update_attributes(:is_deleted => true)
        render :json => @event.as_json
    end
    
    def report
      @report = Report.where(:reported_object => "Stream", :reported_object_id => params[:id], :user_id => current_user.id).first_or_create
      render :json => @report.as_json
    end

end
