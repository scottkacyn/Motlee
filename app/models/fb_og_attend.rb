class FbOgAttend < ActiveRecord::Base

  attr_accessible :fb_attend_id
  belongs_to :event

end
