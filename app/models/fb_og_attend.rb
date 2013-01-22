class FbOgAttend < ActiveRecord::Basei

  attr_accessible :fb_attend_id
  belongs_to :event

end
