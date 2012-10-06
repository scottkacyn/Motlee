class FomosController < ApplicationController
  
  before_filter :load_event

  def index
    @fomos = @event.fomos
  end

  def new
    @fomo = @event.fomos.new
  end

  def create
    if !@event.fomos.where(:user_id => current_user.id).exists?
      @fomo = @event.fomos.new(params[:fomo])
      if @fomo.save  
        redirect_to @event, notice: "Fomo added"
      else
	render :new
      end
    else
      redirect_to @event, notice: "You've already Fomo'd this"
    end
  end

private
  
  def load_event
    @event = Event.find(params[:event_id])
  end

end
