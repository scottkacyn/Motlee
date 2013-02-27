class Api::V1::EventsController < ApplicationController
  
    before_filter :authenticate_user!
    respond_to :json

    # GET
    # /api/events
    def index
        events = current_user.all_events(params[:uids], (params[:updatedAfter] ? params[:updatedAfter] : "2000-01-01T00:00:00.000Z"))
        lat, lon = params[:lat], params[:lon]
        if lat and lon
            events = events.nearby(lat.to_f, lon.to_f)
        end
        render :json => events.as_json(:include => {:location => {}, :photos => {:methods => :owner}, :people_attending => {}}, :methods => [:owner, :attendee_count, :is_attending])
    end

    # GET
    # /api/events/:id
    def show
        @event = Event.find(params[:id])
        @attendee = Attendee.where(:user_id => current_user.id, :event_id => @event.id).first
    
        is_attending = TRUE
        if @attendee.nil?
            is_attending = FALSE
        end

        render :json => { :is_attending => is_attending,
               :event => @event.as_json({:methods => [:owner, :attendee_count], 
               :include => {:photos => {:include => {:comments => {:methods => [:owner]}, :likes => {:methods => [:owner]}}, :methods => :owner}, 
               :stories => {}, 
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
        @event.location_id = location.nil? ? 0 : location.id;
        
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
        event = Event.find(params[:event_id])
        # User is the event creator, has delete priveleges
        mids = params[:ids]
        mid_array = []
        mid_array = mids.split(",")
        mid_array.each do |mid|
            unless (current_user.id == mid)
                @attendee = Attendee.where("user_id = ? AND event_id = ?", mid, params[:event_id])
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
        if (params[:type] == "invite")
            @event = Event.find(params[:event_id])
            @uids = params[:uids]
            @uid_array = []
            @uid_array = @uids.split(",")

            @motlee_users = []
            @non_motlee_users = []

            @uid_array.each do |uid|
                motlee_user = User.where(:uid => uid).first

                if motlee_user.nil?
                    token = params[:access_token]
                    event_id = params[:event_id]
                    Resque.enqueue(ProcessNewUserInvite, token, event_id, uid) 
                else
                    # User is already a part of Motlee
                    # Add user to array of Motlee users
                    @motlee_users << uid
                
                    # Now we check to see if the user has already been added to the event
                    @attendee = Attendee.where("user_id = ? AND event_id = ?", motlee_user.id, params[:event_id]).first
                    if @attendee.nil?
                        # If user has not been added, create new Attendee object
                        @attendee = Attendee.create(:user_id => motlee_user.id, :event_id => params[:event_id], :rsvp_status => 1)
                        if (motlee_user.id != current_user.id)
                            Resque.enqueue(AddEventNotification, motlee_user.id, params[:event_id], current_user.id)
                        end
                    end
                end
            end
            
            # Render a response so the devices are happy
            @event.update_attributes(:updated_at => Time.now)
            if (params[:post_to_fb] == "true")
                Resque.enqueue(PublishFacebookAttend, params[:access_token], params[:event_id], @uids)
            end
            render :json => @event.as_json({:methods => [:owner, :attendee_count], 
                   :include => {:photos => {:include => {:comments => {}, :likes => {}}}, 
                   :people_attending => {:only => [:id, :uid, :name, :sign_in_count]}}})
        end
    end

    def share 
        render :status => 200
    end

    def update
        @event = Event.update(params[:id], params[:event])

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
        @event = Event.find(params[:id])
        @event.update_attributes(:is_deleted => true)
        render :json => @event.as_json
    end

end
