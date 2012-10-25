class Event < ActiveRecord::Base

  has_many :photos
  has_many :stories
  has_one :user
  has_many :fomos
  has_many :attendees

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
	  (attendees.count + 1)
  end

end
