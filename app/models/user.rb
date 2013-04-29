class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :token_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name, :first_name, :last_name, :username, :birthday, :gender, :picture, :sign_in_count, :is_activated
 
  acts_as_tagger
  
  # Setup ActiveRecord associations with other models
  has_many :events
  has_many :photos
  has_many :stories
  has_many :comments
  has_many :likes
  has_many :reports
  has_one :setting
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name: "Relationship",
                                   dependent: :destroy
  has_many :followed_users, :through => :relationships, :source => :followed
  has_many :followers, :through => :reverse_relationships, :source => :follower
  has_many :attendees  
  has_many :events_attended, :through => :attendees, :source => :event
  has_many :favorites
  
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(:name => auth.extra.raw_info.name,
      :provider => auth.provider,
      :uid => auth.uid,
      :first_name => auth.info.first_name,
      :last_name => auth.info.last_name,
      :gender => auth.extra.raw_info.gender,
      :birthday => auth.extra.raw_info.birthday,
      :username => auth.info.username,
      :picture => "https://graph.facebook.com/" + auth.uid + "/picture",
      :email => auth.info.email,
      :is_activated => true,
      :is_private => false,
      :password => Devise.friendly_token[0,20]
      )
    end
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def motlee_friend_uids(access_token)
    # FQL for friends who are also using the Motlee app
    friend_uids = FbGraph::Query.new("SELECT uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = #{self.uid}) AND is_app_user = 1").fetch(access_token)

    # Strip it down to just UIDs instead of hashes because FQL will return an array of hashes containing the UID as a string.
    friend_uids.collect do |friend_uid|
      friend_uid["uid"].to_s
    end
  end

  def motlee_friends(access_token)
    uids = self.motlee_friend_uids(access_token)
    friends = User.where(:uid => uids)
  end

  def streams(updated_at, paging)
    if paging
        Event.from_users_followed_by(self).where("updated_at < ?", updated_at).limit(25)
    else
        Event.from_users_followed_by(self).where("updated_at > ?", updated_at).limit(25)
    end
  end

  def attending?(event)
    events_attended.find(event.id)
  end

  def follower_count
    followers.count
  end

  def following_count
    followed_users.count
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def recent_photos
    photos.recent
  end

  def settings
    settings = Setting.where(:user_id => self.id)
  end

  # ----------------------------------- #
  # Old methods to grandfather v1 users #
  # ----------------------------------- #

  def all_events(access_token, updated_at, paging)
      users = User.where(:uid => self.motlee_friend_uids(access_token))
      user_ids = users.collect do |user|
          user.id
      end.push(self.id)

      if paging
          events = Event.where("updated_at < ?", updated_at)
                        .where("id = ANY (SELECT event_id FROM attendees WHERE user_id = ?) OR (user_id IN (?) AND is_private = 'f')", self.id, user_ids).order("updated_at DESC").limit(25)
      else
          events = Event.where("updated_at > ?", updated_at)
                        .where("id = ANY (SELECT event_id FROM attendees WHERE user_id = ?) OR (user_id IN (?) AND is_private = 'f')", self.id, user_ids).order("updated_at DESC").limit(25)
      end
  end

end
