require 'resque'

module Triangulate

    @queue = :triangulate

    def self.perform(event_id)
        @photos = Photo.where(:event_id => event_id).where('lat != 0').where('lon != 0')
        puts @photos.length
        cart_x = @photos.collect do |photo|
            Math.cos(photo.lat * (Math::PI / 180)) * Math.cos(photo.lon * (Math::PI / 180))
        end
        cart_y = @photos.collect do |photo|
            Math.cos(photo.lat * (Math::PI / 180)) * Math.sin(photo.lon * (Math::PI / 180))
        end
        cart_z = @photos.collect do |photo|
            Math.sin(photo.lat * (Math::PI / 180))
        end

        avg_x = cart_x.inject(:+) / cart_x.length
        avg_y = cart_y.inject(:+) / cart_y.length
        avg_z = cart_z.inject(:+) / cart_z.length

        t_lon = Math.atan2(avg_y, avg_x) * (180 / Math::PI)
        hyp = Math.sqrt((avg_x * avg_x) + (avg_y * avg_y))
        t_lat = Math.atan2(avg_z, hyp) * (180 / Math::PI)

        @event = Event.find(event_id)
        puts "Processed!"
        @event.update_attributes(:lat => t_lat, :lon => t_lon)
    end
end
