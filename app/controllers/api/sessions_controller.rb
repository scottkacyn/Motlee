class Api::SessionsController < Api::BaseController
  prepend_before_filter :require_no_authentication, :only => [:create]
  include Devise::Controllers::InternalHelpers

  before_filter :ensure_params_exist

  respond_to :json

  def create
    build_resource
    resource = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    return invalid_login_attempt unless resource
    
    sign_in("user", resource)
    render :json => { :success => true, :auth_token => resource.authentication_token, :login => resource.login, :email => resource.email }
  end

  def destroy
    sign_out(resource_name)
  end

  protected
  def ensure_params_exist
  end

  def invalid_login_attempt
  end

end
