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

            user.tag(photo, :with => final_tag_list)
            event.tag_list.add(final_tag_list)			
        end
    end
end
