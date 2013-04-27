class Api::V2::LocationsController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
    locations = Location.all
    render :json => locations.as_json
  end

  def create
    location = Location.new(params[:location])
    if location.save
       head :ok
    end
  end
end
