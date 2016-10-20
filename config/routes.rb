Rails.application.routes.draw do
  resources :works
  #devise_for :users
  devise_for :users, :controllers => {:registrations => "registrations"}
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: 'home#homepage'
  
  resources :home
  resources :works
  
  get 'home', :to => "home#homepage"
  post '/works/:id/new_bid', :to => "works#new_bid", :as => "new_bid"
  get '/works/:id/follow', :to => "works#follow", :as => "work_follow"
  get '/list', :to => "works#list", :as => "list"
  get '/categories', :to => "works#categories", :as => "categories"
  get '/works/:id/payments', :to => "works#payments", :as => "payments"
  post "/works/:id/ipn_notify" => "works#ipn_notify", :as => :ipn_notify
  get "/works/:id/pay" => "works#pay"
  get "/works/:id/undo_pay" => "works#undo_pay"
end
