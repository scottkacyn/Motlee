class Api::V1::LocationsController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
    locations = Location.all
    render :json => locations.as_json
  end

  def new
    location = location.new
  end

  def create

    #TODO FIXME
    # If users try to create a location with similar names that are in the same general
    # geographic region, don't let them save a brand new object.

    uid = params[:location]['uid']
    location = Location.where(:uid => uid).first

    if !location.nil?
      # Location with that UID already exists in the DB
      render :json => location.as_json
    else
      location = Location.new(params[:location])
      if location.save
	render :json => location.as_json, :status => :created
      else
	render :json => location.errors, :status => :unprocessable_entity
      end
    end
  end

end
