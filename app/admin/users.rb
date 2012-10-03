ActiveAdmin.register User do

  menu :label => "Motlee Users"
  config.per_page = 10
  
  index do
    column "Photo" do |user|
      image_tag("https://graph.facebook.com/" + user.uid + "/picture")
    end
    column "Name" do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    default_actions
  end

end
