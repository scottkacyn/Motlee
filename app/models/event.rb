class Event < ActiveRecord::Base
  
  COORDINATE_DELTA = 0.05

  acts_as_taggable

  has_one :user
  has_one :fb_og_attend
  belongs_to :location
  has_many :attendees
  has_many :people_attending, :through => :attendees, :source => :user
  has_many :favorites
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

  def watched_by?(user)
    favorites.find_by_user_id(user.id)
  end

  def watch_for(user)
    favorites.create!(user_id: user.id)
  end

  def unwatch_for(user)
    favorites.find_by_user_id(user.id).destroy
  end

  def self.from_users_with_ids(user_ids)
    where("id = ANY (SELECT event_id FROM attendees WHERE user_id IN (:user_ids)) OR (user_id IN (:user_ids) AND is_private = 'f')", user_ids: user_ids).order("updated_at DESC").limit(25)
  end
    
  
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
            user_id: user.id)
  end

  def self.favorites_for_user(user)
    favorited_stream_ids = "SELECT event_id FROM favorites
                            WHERE user_id = :user_id"
    where("id IN (#{favorited_stream_ids})", user_id: user.id)
  end

  def self.tagged_with_tag(query, page)
    tagged_with(query).popular.paginate(:page => page, :per_page => 20).uniq!
  end

  scope :nearby, lambda { |lat,lon|
        where("updated_at > ?", (Time.now - 24.hours)).
	where("lat BETWEEN ? AND ?", lat - COORDINATE_DELTA, lat + COORDINATE_DELTA).
	where("lon BETWEEN ? AND ?", lon - COORDINATE_DELTA, lon + COORDINATE_DELTA).
        where("id = ANY (SELECT event_id FROM photos WHERE created_at > ?)", (Time.now - 24.hours)).
	limit(20)
  }

  scope :popular, order("updated_at DESC")
        
end
