class Story < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  belongs_to :comment_thread
  belongs_to :like_thread
end
