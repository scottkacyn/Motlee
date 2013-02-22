class Api::V1::PhotosController < ApplicationController
  
	before_filter :load_event_if_exists, :authenticate_user!
	
	respond_to :json

        # GET /photos
        # Returns all photos for a particular event
        # Optional lat, lon params provide events near a geographic coordinate
	def index
	  lat, lon = params[:lat], params[:lon]
	  if lat and lon
              @photos = Photo.nearby(lat.to_f, lon.to_f)
              render :json => @photos._as_json
	  else
            if !@event.nil?
              @photos = @event.photos
              render :json => @photos.as_json(
                    {:methods => [:owner],
                     :include => {:comments => {:methods => [:owner]},
                                  :likes => {:methods => [:owner]}}})
            else
              @photos = Photo.all
              render :json => @photos.as_json
            end
	  end
	end

        # GET /photos/1
        # Returns information for a particular photo
	def show
            @photo = Photo.find(params[:id])
            render :json => @photo.as_json(
                    {:methods => [:owner],
                     :include => {:comments => {:methods => [:owner]},
                                  :likes => {:methods => [:owner]}}})
	end
	
        # POST /photos
        # Creates a new photo object
	def create
	  @photo = Photo.new(params[:photo])
	  @photo.user_id = current_user.id
	  @photo.event_id = @event.id

	  if @photo.save

            @photos = @event.photos
            cart_x = @photos.collect do |photo|
                Math.cos(photo.lat * (Math.pi / 180)) * Math.cos(photo.lon * (Math.pi / 180))
            end
            cart_y = @photos.collect do |photo|
                Math.cos(photo.lat * (Math.pi / 180)) * Math.sin(photo.lon * (Math.pi / 180))
            end
            cart_z = @photos.collect do |photo|
                Math.sin(photo.lat * (Math.pi / 180))
            end

            avg_x = cart_x.inject(:+) / cart_x.length
            avg_y = cart_y.inject(:+) / cart_y.length
            avg_z = cart_z.inject(:+) / cart_z.length

            t_lon = Math.atan2(avg_y, avg_x) * (180 / Math.pi)
            hyp = Math.sqrt((avg_x * avg_x) + (avg_y * avg_y))
            t_lat = Math.atan2(avg_z, hyp) * (180 / Math.pi)

	    @event.update_attributes(:updated_at => @photo.updated_at, :lat => t_lat, :lon => t_lon)
 	    render :json => @photo, :status => :created
	  else
	    render :json => @photo.errors, :status => :unprocessable_entity
          end	
	end

        def destroy
          @photo = Photo.find(params[:id])
          if (@photo.user_id == current_user.id)
            @photo.destroy
            @event.update_attributes(:updated_at => @photo.updated_at)
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
