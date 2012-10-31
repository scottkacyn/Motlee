require 'api_constraints'

Motlee::Application.routes.draw do
  
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => { :sessions => 'users/sessions', :omniauth_callbacks => 'users/omniauth_callbacks' }

  resources :events do
    resources :stories do
      resources :comments
      resources :likes
    end
    resources :photos do
      resources :comments
      resources :likes
    end
    resources :fomos
  end
  resources :locations
  resources :comments, :only => [:index]

  # PAGES - get
  get "pages/index"
  get "pages/about"
  get "pages/company"
  get "pages/contact"
  get "pages/jobs"
  get "pages/api"

  # PAGES - match
  match 'about' => 'pages#about'
  match 'company' => 'pages#company'
  match 'contact' => 'pages#contact'
  match 'jobs' => 'pages#jobs'
  match 'api' => 'pages#api'

  # USER TOKEN AUTHENTICATION
  namespace :api, defaults: {format: 'json'} do
    match '/' => 'api#index', :via => :get
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :events do
	collection do
	  match ':event_id/join' => 'events#join', :via => :post
	  match ':event_id/photos' => 'photos#index', :via => :get
	end
        resources :stories do
	  resources :comments
	  resources :likes
	end
      end
      resources :users, :only => [:index, :show]
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
