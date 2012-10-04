class Event < ActiveRecord::Base

  has_many :fomos
  has_many :attendees

  has_many :users, :through => :fomos
  has_many :users, :through => :attendees

end
