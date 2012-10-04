class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid,
                  :name, :first_name, :last_name, :birthday, :gender, :picture
  
  
  # Setup ActiveRecord associations with other models
  has_many :events
  has_many :photos
  has_many :stories
  has_many :comments
  has_many :fomos
  has_many :likes
  
  has_many :comment_threads, :through => :comments
  has_many :fomos, :through => :events
  has_many :events, :through => :attendees

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
      :picture => "https://graph.facebook.com/" + auth.uid + "/picture?type=normal",
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

end
