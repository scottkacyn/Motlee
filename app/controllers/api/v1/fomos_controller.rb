class Api::V1::FomosController < ApplicationController
  
  before_filter :load_event, :authenticate_user!

  def index
    @fomos = @event.fomos
    render :json => @fomos
  end

  def new
    @fomo = @event.fomos.new
  end

  def create
    if !@event.fomos.where(:user_id => current_user.id).exists?
      @fomo = @event.fomos.new(params[:fomo])
      @fomo.user_id = current_user.id
      if @fomo.save  
        render :json => @fomo, :status => :created
      else
	render :json => @fomo.errors, :status => :unprocessable_entity
      end
    else
      @fomo = @event.fomos.where(:user_id => current_user.id).first
      if @fomo.destroy
	      render :json => {:message => "Event was un-fomoed"}
      else
	      render :json => {:message => "Something went wrong"}
      end
    end
  end

private
  
  def load_event
    @event = Event.find(params[:event_id])
  end

end
