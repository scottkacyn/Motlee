class PagesController < ApplicationController

  before_filter :authenticate_user!, :only => :stats

  def index
    @leads = Leads.new
  end

  def about
  end

  def company
  end

  def contact
  end

  def jobs
  end

  def api
  end

  def terms
  end

  def privacy
  end

  def support
  end

  def stats
    @users = User.all
    @actives = User.where("sign_in_count > 0");
    @events = Event.all
    @event = Event.new
    @photos = Photo.all.count
    @latest = Photo.order("created_at DESC").limit(100)
  end

  def live
    @event = Event.find(params[:event_id])
  end

end
