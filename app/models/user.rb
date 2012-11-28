class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :token_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :email, :password, :password_confirmation, :remember_me, :provider, :uid,
                  :name, :first_name, :last_name, :birthday, :gender, :picture
  
  
  # Setup ActiveRecord associations with other models
  has_many :events
  has_many :photos
  has_many :stories
  has_many :comments
  has_many :fomos
  has_many :likes
  has_many :attendees

  has_many :events_attended, :through => :attendees, :source => :event
  has_many :events_fomoed, :through => :fomos, :source => :event	
  
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
      :picture => "https://graph.facebook.com/" + auth.uid + "/picture",
      :email => auth.info.email,
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

    #fb_user = FbGraph::User.me(access_token)
    # FQL for "friends who are using the FanTravel app"
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

  def all_events(access_token, updated_at)
	  users = User.where(:uid => self.motlee_friend_uids(access_token))
	  user_ids = users.collect do |user|
		  user.id
	  end.push(self.id)
	  events = Event.where("updated_at > ?", updated_at).where(:user_id => user_ids)
  end
end
