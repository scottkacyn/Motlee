class Event < ActiveRecord::Base

  COORDINATE_DELTA = 0.05

  has_many :photos
  has_many :stories
  has_one :user
  has_one :fb_og_attend
  belongs_to :location
  has_many :attendees
  has_many :people_attending, :through => :attendees, :source => :user

  def owner

    puts "Finding the owner for this event"

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
        where("updated_at > ?", (Time.now - 24.hours)).
	where("lat BETWEEN ? AND ?", lat - COORDINATE_DELTA, lat + COORDINATE_DELTA).
	where("lon BETWEEN ? AND ?", lon - COORDINATE_DELTA, lon + COORDINATE_DELTA).
        where("id = ANY (SELECT event_id FROM photos WHERE created_at > ?)", (Time.now - 24.hours)).
	limit(20)
  }

end
