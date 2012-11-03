class Event < ActiveRecord::Base

  COORDINATE_DELTA = 0.05

  has_many :photos
  has_many :stories
  has_one :user
  has_one :location
  has_many :fomos
  has_many :attendees

  has_many :people_attending, :through => :attendees, :source => :user
  has_many :fomoers, :through => :fomos, :source => :user

  def owner
	  if (user_id == 0 || !user_id)
		  return
	  end
	  @owner = User.find(user_id)
	  [:id => @owner.id, :uid => @owner.uid, :name => @owner.name]
  end

  def fomo_count
	  fomos.count
  end

  def attendee_count
	  attendees.count
  end

  scope :nearby, lambda { |lat,lon|
	where("lat BETWEEN ? AND ?", lat - COORDINATE_DELTA, lat + COORDINATE_DELTA).
	where("lon BETWEEN ? AND ?", lon - COORDINATE_DELTA, lon + COORDINATE_DELTA).
	limit(64)
  }


end
