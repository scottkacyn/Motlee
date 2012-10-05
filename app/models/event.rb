class Event < ActiveRecord::Base

  has_many :photos
  has_many :stories
  has_one :user
  has_many :fomos
  has_many :attendees

end
