class Location < ActiveRecord::Base

  has_many :events

  def self.find_or_create_with_params(params)
    uid = params['uid']
    if uid.nil? or uid == 0
        # User is creating a custom location
        # We don't do anything at this point
        location = Location.create(params)
    else
        # User has selected a place from FB places
        # 1) First, check to see if it's stored...
        location = Location.where(:uid => uid).first
        unless location
            location = Location.create(params)
        end
    end
    location
  end
 
end
