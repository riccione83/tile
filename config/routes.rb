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
  resources :payments
  
  get 'home', :to => "home#homepage"
  post '/works/:id/new_bid', :to => "works#new_bid", :as => "new_bid"
  get '/works/:id/follow', :to => "works#follow", :as => "work_follow"
  get '/list', :to => "works#list", :as => "list"
  get '/categories', :to => "works#categories", :as => "categories"
  get '/works/:id/payments', :to => "works#make_payment", :as => "make_payment"
  
  post "/works/:id/ipn_notify/:user_id" => "works#ipn_notify", :as => :ipn_notify
  get "/works/:id/pay/:user_id" => "works#pay"
  get "/works/:id/undo_pay/:user_id" => "works#undo_pay"
  
  get "/payments_in", :to => "payments#ricevuti", :as => :payment_in
  get "/payments_out", :to => "payments#inviati", :as => :payment_out
  get "/payments/done/:id/:user_id" => "payments#done", :as => :payment_done

end
