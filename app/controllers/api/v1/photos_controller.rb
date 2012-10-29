class Api::V1::PhotosController < ApplicationController
	
	respond_to :json

	def index
	  lat, lon = params[:at], params[:lon]
	  if lat and lon
		  @photos = Photo.nearby(lat.to_f, lon.to_f)
		  respond_with({:photos => @photos}.as_json)
	  else
		@photos = Photo.all
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

end
