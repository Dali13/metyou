Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  devise_for :users, controllers: {registrations: 'registrations', sessions: 'sessions', unlocks: 'unlocks'}
  authenticated :user do
    root 'posts#index', as: :authenticated_root
  end

  # You can have the root of your site routed with "root"
   root 'pages#home'
   resources :posts do
     collection do
       post '/autocomplete', to: 'posts#autocomplete'
       get '/search' => 'posts#search'
       get '/unpublished' => 'posts#unpublished'
       get '/flaged' => 'posts#flaged'
     end
     member do
       post 'send_message', to: 'posts#send_message'
       patch 'publish', to: 'posts#publish'
       get 'flag', to: 'posts#flag'
       post 'unflag', to: 'posts#unflag'
       post 'post_flag', to: 'posts#post_flag'
       get 'reporting', to: 'posts#reporting'
     end
     
   end
  #resources :messages, only: [:create]
   
   resources :users do
     member do
       get 'myposts', to: 'users#myposts'
       delete 'avatar', to: 'users#avatar'
       delete 'image', to: 'users#image'
       get 'report', to: 'users#report'
       post 'unreport', to: 'users#unreport'
       post 'post_report', to: 'users#post_report'
       post 'block', to: 'users#block'
       post 'unblock', to: 'users#unblock'
       get 'reporting', to: 'users#reporting'
     end
     collection do
       get 'settings', to: 'users#settings'
       patch 'update_password', to: 'users#update_password'
       get 'blocked', to: 'users#blocked'
       get 'reported', to: 'users#reported'
       get 'searching_form', to: 'users#searching_form'
       get 'search', to: 'users#search'
     end
   end
  require 'sidekiq/web' 
  require 'sidekiq/cron/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
   
   
  # resources :albums, only: [:destroy]

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
