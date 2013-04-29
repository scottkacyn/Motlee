require 'resque'

module SetTags

    @queue = :set_tags

    def self.perform(event_id, photo_id, caption)
        hashtags = caption.scan(/#\w+/)
        final_tag_list = []

        hashtags.each do |hashtag|
            hashtag.slice!(0)
            final_tag_list << hashtag
        end
        
        if final_tag_list.length > 0
            event = Event.find(event_id)
            photo = Photo.find(photo_id)
            user = User.find(photo.user_id)

            current_event_tags = event.tags_from(user)
            current_photo_tags = photo.tags_from(user)

            user.tag(photo, :with => final_tag_list + current_photo_tags, :on => :tags)
            user.tag(event, :with => final_tag_list + current_event_tags, :on => :tags)	
        end
    end
end
