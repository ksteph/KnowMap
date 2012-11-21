KnowledgeMap::Application.routes.draw do

  resources :node_indices

  root :to => "graphs#index"

  get 'search/(:q)' => "search#search", :as => "search"

  resources :graphs do
    get "groups_widget" => "graphs#groups_widget", :as => "groups_widget"
    get "versions" => "graphs#versions", :as => "versions"
    get "versions/:version" => "graphs#version", :as => "version"
  end

  resources :nodes do
    get "learning_path" => "nodes#learning_path", :as => "learning_path"
    get "node_widget" => "nodes#node_widget", :as => "node_widget"
    get "versions" => "nodes#versions", :as => "versions"
    get "versions/:version" => "nodes#version", :as => "version"
    get "node_stats" => "nodes#node_stats", :as => "node_stats"
    resources :questions do
      put "submit" => "questions#submit", :as => "question_submit"
    end
  end

  resources :courses do
    get "syllabus" => "courses#syllabus", :as => "syllabus"
  end

  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"
  get "sign_up" => "users#new", :as => "sign_up"
  get "profile" => "users#profile", :as => "profile"
  
  scope "account" do
    get "/" => "users#account", :as => "account"
    get "/edit" => "users#edit", :as => "edit_account"
    get "/profile" => "users#profile", :as => "profile" # what other users see
    match "/change_password" => "users#change_password", :as => "change_password"
  end

  resources :users
  resources :sessions
  resources :roles
  resources :actions
  
  #resources :graph_membership_graphs
  #resources :graph_membership_nodes
  #resources :edges
  #resources :edgetypes
  #resources :course_memberships
  
  get "/log/(:log_controller)/(:target_id)/(:log_action)" => "application#log"
  
  match "/_partials/(:partial)" => 'application#partial'
  
  get 'data.json' => "application#data"
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
