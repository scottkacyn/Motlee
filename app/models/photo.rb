class Photo < ActiveRecord::Base
  
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/gif']

  COORDINATE_DELTA = 0.05	

  has_attached_file :image,
	  :styles => { :thumbnail => "200x200#",
		       :compressed => "800x800#" },
  	  :storage => :s3,
	  :bucket => ENV['S3_BUCKET'],
	  :s3_credentials => {
	  	:access_key_id => ENV['S3_KEY'],
		:secret_access_key => ENV['S3_SECRET'] }
  
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
    [:id => self.user_id]
  end
   
end
