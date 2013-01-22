class Photo < ActiveRecord::Base
  
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  
  COORDINATE_DELTA = 0.05	

#TODO TAKE OUT THE HARD CORDED AWS INFORMATION YOU JACKASS

  has_attached_file :image,
	  :styles => { :thumbnail => "200x200#",
		       :compressed => "720x720#" },
  	  :storage => :s3,
	  :bucket => 'motlee-staging-photos',
	  :s3_credentials => {
	  	:access_key_id => "AKIAIZEAHVEKVBBVZAVQ",
		:secret_access_key => "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",
  	  }
  process_in_background :image
  
  belongs_to :user
  belongs_to :event

  has_many :comments, as: :commentable
  has_many :likes, as: :likeable

  scope :recent, order("created_at DESC")

  scope :nearby, lambda { |lat,lon|
	  where("lat BETWEEN ? AND ?", lat - COORDINATE_DELTA, lat + COORDINATE_DELTA).
	  where("lon BETWEEN ? AND ?", lon - COORDINATE_DELTA, lon + COORDINATE_DELTA).
	  limit(64)
  }
  
  def owner
	  if (user_id == 0 || !user_id)
		  return
	  end
	  @owner = User.find(user_id)
	  [:id => @owner.id, :uid => @owner.uid, :name => @owner.name]
  end
   
end
