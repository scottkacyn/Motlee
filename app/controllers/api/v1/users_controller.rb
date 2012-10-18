class Api::V1::UsersController < ApplicationController
  
  before_filter :authenticate_user!

  respond_to :json

  def index
    respond_with current_user.to_json
  end

end
