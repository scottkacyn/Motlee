require 'api_constraints'
require 'resque/server'

Motlee::Application.routes.draw do

  mount Resque::Server.new, :at => "/resque"
  
  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }
  
  resources :events do
    member do
      get :live
    end
    resources :photos
  end
  resources :users
  resources :relationships, :only => [:create, :destroy]
  resources :locations
  resources :leads, :only => [:index, :show, :create]
  
  # ----- #
  # PAGES #
  # ----- #
  match 'terms' => 'pages#terms', :via => :get
  match 'about' => 'pages#about', :via => :get
  match 'support' => 'pages#support', :via => :get
  match 'privacy' => 'pages#privacy', :via => :get
  match 'company' => 'pages#company', :via => :get
  match 'contact' => 'pages#contact', :via => :get
  match 'jobs' => 'pages#jobs', :via => :get
  match 'stats' => 'pages#stats', :via => :get
  match 'api' => 'pages#api', :via => :get
  match 'godview' => 'pages#godview', :via => :get
  match 'live' => 'pages#live', :via => :get
  match 'test' => 'pages#test', :via => :get

  # ----------------- #
  # Routes for API:V1 #
  # ----------------- #
  namespace :api, defaults: {format: 'json'} do
    match '/' => 'api#index', :via => :get

    # --------- #
    # VERSION 1 #
    # --------- #
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :events do
        member do
          post :report, :join, :unjoin, :share
        end
	resources :photos do
          member do
            put :update_caption
            post :report
          end
          collection do
            post :temp
          end
	  resources :comments 
	  resources :likes
	end
      end
      resources :users do
        member do
            get :following, :followers, :friends, :notifications, :settings
            post :device
        end
	collection do
            post :device
	end
      end
      resources :photos, :only => :index
      resources :relationships, :only => [:create, :destroy]
      resources :locations, :only => [:index, :new, :create]
      resources :tokens, :only => [:create, :destroy]
    end
    
    # --------- #
    # VERSION 2 #
    # --------- #
    
    scope module: :v2, constraints: ApiConstraints.new(version: 2) do
      resources :events do
        member do
          get :attendees, :favorites
          post :report, :join, :unjoin, :share, :add_favorite
        end
	resources :photos do
          member do
            put :update_caption
            post :report
          end
          collection do
            post :temp
          end
	  resources :comments 
	  resources :likes
	end
      end
      resources :users do
        member do
            get :following, :followers, :friends, :notifications, :settings
            post :device
        end
	collection do
            post :device
	end
      end
      resources :photos, :only => :index
      resources :relationships, :only => [:create, :destroy]
      resources :locations, :only => [:index, :new, :create]
      resources :tokens, :only => [:create, :destroy]
    end
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "pages#index"

end
