class Like < ActiveRecord::Base
  
  attr_accessible :user_id

  belongs_to :user
  belongs_to :likeable, polymorphic: true

  def owner
      if (user_id == 0 || !user_id)
              return
      end
      @owner = User.find(user_id)
      [:id => @owner.id, :uid => @owner.uid, :name => @owner.name]
  end
end
