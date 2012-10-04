ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do
	h2 do
	  "Users"
	end
        panel "Total Signups" do 
	  h1 do
	    User.count
	  end
	end
        panel "Average Logins/User" do 
	  h1 do
	    User.average(:sign_in_count).to_i
	  end
	end
        panel "Recent Signups" do 
	  ul do
	    User.last(5).map do |user|
	      li link_to(user.name, admin_user_path(user))
	    end
	  end
	end
      end
      column do
	h2 do
	  "Events"
	end
        panel "Events Created" do 
	  h1 do
	    Event.count
	  end
	end
        panel "Average Events/User" do 
	  h1 do
	    (Event.count / User.count).to_i
	  end
	end
      end
      column do
      end
    end

  end # content

end
