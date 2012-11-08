class Api::V1::PhotosController < ApplicationController
  
	before_filter :load_event_if_exists
	
	respond_to :json

	def index
	  lat, lon = params[:lat], params[:lon]
	  if lat and lon
		  @photos = Photo.nearby(lat.to_f, lon.to_f)
		  respond_with({:photos => @photos}.as_json)
	  else
		@photos = @event.photos
		render :json => @photos.as_json(:methods => [:owner])
	  end
	end

	def show
		@photo = Photo.find(params[:id])
		render :json => @photo.as_json(:methods => [:owner])
	end
	
	def create
	  @photo = Photo.new(params[:photo])
	  if @photo.save
	    render :json => @photo, :status => :created
	  else
	    render :json => @photo.errors, :status => :unprocessable_entity
          end	
	end

private

  def load_event_if_exists
    @event = Event.find(params[:event_id])
  end
end
