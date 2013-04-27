class Api::V1::SettingsController < ApplicationController
    
    before_filter :authenticate_user!
    respond_to :json

    def index
        settings = current_user.settings
        if settings.empty? || settings.nil?
            settings = Setting.create(:fb_on_event_create => false, :fb_on_event_invite => false, :on_event_invite => false, :on_event_message => false, :on_photo_comment => false, :on_photo_like => false, :on_friend_join => false, :user_id => current_user.id)
        end
        render :json => settings.as_json
    end

    def create
        if settings.empty? || settings.nil?
            settings = Setting.new(:fb_on_event_create => false, :fb_on_event_invite => false, :on_event_invite => false, :on_event_message => false, :on_photo_comment => false, :on_photo_like => false, :on_friend_join => false, :user_id => current_user.id)
            if settings.save
                render :json => settings.as_json, :status => :created
            else
                render :json => settings.errors, :status => :unprocessable_entity
            end
        end
    end

    def update
        settings = Setting.update(params[:id], params[:settings])
        render :json => settings.as_json
    end

    def destroy
        respond_with Setting.destroy(params[:id])
    end

end
