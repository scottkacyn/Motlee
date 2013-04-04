class PagesController < ApplicationController

  before_filter :authenticate_user!, :only => [:stats, :godview]

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

  def test
  end

  def stats
    @users = User.all
    @actives = User.where("sign_in_count > 0");
    @events = Event.all
    @reports = Report.all
    @event = Event.new
    @photos = Photo.all.count
    @latest = Photo.order("created_at DESC").limit(100)
  end

  def godview
    @photos = Photo.order("created_at DESC").limit(100)
  end

  def live
    @photos = Photo.where(:event_id => params[:event_id]).order("created_at DESC")
    render :layout => "live"
  end

end
