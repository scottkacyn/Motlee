class Photo < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_one :comment_thread
  has_one :like_thread
end
