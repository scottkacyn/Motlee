class Event < ActiveRecord::Base

  has_one :user
  has_one :fb_og_attend
  belongs_to :location
  has_many :attendees
  has_many :people_attending, :through => :attendees, :source => :user
  has_many :photos, :conditions => 'is_uploaded = true'

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

  def first_photos
    @photos = photos.limit(3)
    @photos.as_json(:methods => :owner)
  end

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
            user_id: user.id)
  end

  COORDINATE_DELTA = 0.05
  scope :nearby, lambda { |lat,lon|
        where("updated_at > ?", (Time.now - 24.hours)).
	where("lat BETWEEN ? AND ?", lat - COORDINATE_DELTA, lat + COORDINATE_DELTA).
	where("lon BETWEEN ? AND ?", lon - COORDINATE_DELTA, lon + COORDINATE_DELTA).
        where("id = ANY (SELECT event_id FROM photos WHERE created_at > ?)", (Time.now - 24.hours)).
	limit(20)
  }

end
