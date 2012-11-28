class Api::V1::LocationsController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
    locations = Location.all
    render :json => locations.as_json
  end

  def create

    #TODO FIXME
    # If users try to create a location with similar names that are in the same general
    # geographic region, don't let them save a brand new object.

    uid = params[:location]['uid']
   
    if uid.nil?
      # User is creating a custom location, not based on Facebook Places
      # TODO This currently does not allow user to choose from our custom
      # locations db in the app, requires user to create from Facebook or a
      # one-off custom location.
      # location = Location.new(params[:location])
    else
      # User has either selected from FB or addinga  new FB
      location = Location.where(:uid => uid).first
      if !location.nil?
        # Location with that UID already exists in the DB
	return
      end
    end
    
    location = Location.new(params[:location])
    location.uid = 0
    location.fsid = 0
    if location.save
       head :ok
    end
  end
end
