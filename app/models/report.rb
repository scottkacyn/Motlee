class Report < ActiveRecord::Base
  belongs_to :user
  attr_accessible :object, :object_id
end
