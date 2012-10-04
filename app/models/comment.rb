class Comment < ActiveRecord::Base
  attr_accessible :user_id, :body
  belongs_to :user
  belongs_to :commentable, polymorphic: true
end
