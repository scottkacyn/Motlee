class ApplicationController < ActionController::Base
  protect_from_forgery

  def check_for_mobile
    if request.user_agent =~ /Android/i
        redirect_to "https://play.google.com/store/apps/details?id=com.motlee.android"
    end
  end
  helper_method :check_for_mobile

end
