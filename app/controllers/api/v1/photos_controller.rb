class Api::V1::PhotosController < ApplicationController
  
	before_filter :load_event_if_exists
	
	respond_to :json

	def index
	  lat, lon = params[:at], params[:lon]
	  if lat and lon
		  @photos = Photo.nearby(lat.to_f, lon.to_f)
		  respond_with({:photos => @photos}.as_json)
	  else
		@photos = @event.photos
		respond_with({:photos => @photos}.as_json)
	  end
	end

	def show
		@photo = Photo.find(params[:id])
		respond_with(@photo)
	end

	def create
		@photo = Photo.create(params[:photo])
		respond_with(@photo)
	end

private

  def load_event_if_exists
    @event = Event.find(params[:event_id])
  end
end
