class Story < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :event

  has_many :comments, as: :commentable
  has_many :likes, as: :likeable

  def owner
	  if (user_id == 0 || !user_id)
		  return
	  end
	  @owner = User.find(user_id)
	  [:id => @owner.id, :uid => @owner.uid, :name => @owner.name]
  end

end
