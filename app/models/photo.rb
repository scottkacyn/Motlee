class Photo < ActiveRecord::Base
  
  COORDINATE_DELTA = 0.05	
	
  belongs_to :user
  belongs_to :event

  has_many :comments, as: :commentable
  has_many :likes, as: :likeable

  has_attached_file :image,
	  :styles => { :thumbnail => "92x92#",
		       :iphone	  => "320" },
  	  :storage => :s3,
	  :s3_credentials => S3_CREDENTIALS

  scope :nearby, lambda { |lat,lon|
	  where("lat BETWEEN ? AND ?", lat - COORDINATE_DELTA, lat + COORDINATE_DELTA).
	  where("lon BETWEEN ? AND ?", lon - COORDINATE_DELTA, lon + COORDINATE_DELTA).
	  limit(64)
  }
   
end
