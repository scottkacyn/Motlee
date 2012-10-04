class Photo < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  has_many :comments, as: :commentable
  has_many :likes, as: :likeable

end
