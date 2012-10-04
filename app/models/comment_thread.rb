class CommentThread < ActiveRecord::Base
  belongs_to :photo
  belongs_to :story

  has_many :users, :through => :comments
end
