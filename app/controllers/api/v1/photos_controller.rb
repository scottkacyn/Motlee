class Api::V1::PhotosController < ApplicationController
  
	before_filter :load_event_if_exists, :authenticate_user!
	
	respond_to :json

        # GET /photos
        # Returns all photos for a particular event
	def index
	  lat, lon = params[:lat], params[:lon]
	  if lat and lon
		  @photos = Photo.nearby(lat.to_f, lon.to_f)
		  respond_with({:photos => @photos}.as_json)
	  else
		if !@event.nil?
		  @photos = @event.photos
		else
		  @photos = Photo.all
		end
		render :json => @photos.as_json(:include => [:comments, :likes], :methods => [:owner])
	  end
	end

        # GET /photos/1
        # Returns information for a particular photo
	def show
		@photo = Photo.find(params[:id])
		render :json => @photo.as_json(:include => [:comments, :likes], :methods => [:owner])
	end
	
        # POST /photos
        # Creates a new photo object
	def create
	  @photo = Photo.new(params[:photo])
	  @photo.user_id = current_user.id
	  @photo.event_id = @event.id

	  if @photo.save
	    @event.update_attributes(:updated_at => @photo.updated_at)
 	    render :json => @photo, :status => :created
	  else
	    render :json => @photo.errors, :status => :unprocessable_entity
          end	
	end

        def destroy
          @photo = Photo.find(params[:id])
          if (@photo.user_id == current_user.id)
            @photo.destroy
            render :json => @photo
          else
            render :status => :forbidden
          end
        end

private

  def load_event_if_exists
	  @event = nil
	  if (params[:event_id])
		  @event = Event.find(params[:event_id])
	  end
  end
end
