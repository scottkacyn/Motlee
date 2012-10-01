class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :like_thread
end
