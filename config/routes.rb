require 'api_constraints'
require 'resque/server'

Motlee::Application.routes.draw do

  mount Resque::Server.new, :at => "/resque"
  
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => { :sessions => 'users/sessions', :omniauth_callbacks => 'users/omniauth_callbacks' }

  resources :users
  resources :events do
    resources :stories do
      resources :comments
      resources :likes
    end
    resources :photos do
    end
    resources :fomos
  end
  resources :locations

  # PAGES - get
  get "pages/index"
  get "pages/terms"
  get "pages/about"
  get "pages/support"
  get "pages/privacy"
  get "pages/company"
  get "pages/contact"
  get "pages/jobs"
  get "pages/stats"
  get "pages/api"

  # PAGES - match
  match 'about' => 'pages#about', :via => :get
  match 'terms' => 'pages#terms', :via => :get
  match 'stats' => 'pages#stats', :via => :get
  match 'support' => 'pages#support', :via => :get
  match 'privacy' => 'pages#privacy', :via => :get
  match 'company' => 'pages#company', :via => :get
  match 'contact' => 'pages#contact', :via => :get
  match 'jobs' => 'pages#jobs', :via => :get
  match 'api' => 'pages#api', :via => :get

  resources :leads, :only => [:index, :show, :create]

  # Routes for API:V1
  #
  namespace :api, defaults: {format: 'json'} do
    match '/' => 'api#index', :via => :get
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :events do
	collection do
	  match 'fbfriends' => 'events#fb_friends', :via => :get
	  match ':event_id/join' => 'events#join', :via => :post
          match ':event_id/unjoin' => 'events#unjoin', :via => :post
	end
	resources :photos do
	  resources :comments 
	  resources :likes
	end
      end
      resources :photos, :only => :index
      resources :users do
	collection do
	  match ':user_id/friends' => 'users#friends', :via => :get
          match ':user_id/notifications' => 'users#notifications', :via => :get
          match ':user_id/settings' => 'settings#index', :via => :get
	end
      end
      resources :locations, :only => [:index, :new, :create]
      resources :tokens, :only => [:create, :destroy]
    end
  end


  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "pages#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
