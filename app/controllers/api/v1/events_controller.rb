class Api::V1::EventsController < ApplicationController
  
    before_filter :authenticate_user!
    respond_to :json

    # GET
    # /api/events
    def index
        lat, lon = params[:lat], params[:lon]
        if lat and lon
            events = Event.nearby(lat.to_f, lon.to_f)
        else
            events = current_user.all_events(params[:access_token], (params[:updatedAfter] ? params[:updatedAfter] : "2000-01-01T00:00:00.000Z"))
        end
        render :json => events.as_json(:include => [:location, :photos, :stories, :people_attending], :methods => [:owner, :attendee_count, :is_attending])
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
               :include => {:photos => {:include => {:comments => {}, :likes => {}}}, 
               :stories => {}, 
               :people_attending => {:only => [:id, :uid, :name]}}})}
    end

    # POST
    # /api/events
    def create
        @event = Event.new(params[:event]) 
        @event.user_id = current_user.id
        if (@event.name.blank?)
            return
        end
        
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
                    # User is not registered with Motlee yet.
                    # Add user to array of non-Motlee users
                    @non_motlee_users << uid
                    http = Curl.get("https://graph.facebook.com/" + uid)
                    result = JSON.parse(http.body_str)
                    
                    email = ''
                    if result['email'].nil?
                      if result['username'].nil?
                        email = uid + "@facebook.com"
                      else
                        email = result['username'] + "@facebook.com"
                      end
                    else
                      email = result['email']
                    end

                    gender = ''
                    if result['gender'].nil?
                      gender = 'unknown'
                    else
                      gender = result['gender']
                    end

                    birthday = ''
                    if result['birthday'].nil?
                      birthday = 'unknown'
                    else
                      birthday = result['birthday']
                    end

                    username = ''
                    if result['username'].nil?
                      username = 'unknown'
                    else
                      username = result['username']
                    end
                    user = User.create(:name => result['name'],
                                       :provider => "facebook",
                                       :uid => result['id'],
                                       :email => email,
                                       :first_name => result['first_name'],
                                       :last_name => result['last_name'],
                                       :birthday => birthday,
                                       :username => username,
                                       :gender => gender,
                                       :picture => "https://graph.facebook.com/" + uid + "/picture",
                                       :password => Devise.friendly_token[0,20]
                                      )
                    @attendee = Attendee.create(:user_id => user.id, :event_id => params[:event_id], :rsvp_status => 1)
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
            render :json => {:message => "Attendees were added to the event"}
        else
            @attendee = Attendee.where("user_id = ? AND event_id = ?", current_user.id, params[:event_id]).first
            if @attendee.nil?
                # If user has not been added, create new Attendee object
                @attendee = Attendee.create(:user_id => current_user.id, :event_id => params[:event_id], :rsvp_status => 1)

                # Add a Facebook Open Graph post
                token = params[:access_token]
                url = "http://www.motleeapp.com/events/" + params[:event_id]

                Resque.enqueue(PublishFbOgAction, token, url)
            end
            render :json => {:message => url}
        end
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

        render :json => @event.as_json
    end

    def destroy
        respond_with Event.destroy(params[:id])    
    end

end
