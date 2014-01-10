Weatherapp::Application.routes.draw do
  get "dashboard/index"
  get "utilities/getFlickrImages"
  get "utilities/getWeatherData"
  get "utilities/getReverseGeolocation"
  get "utilities/getGeolocation"
  
  get "api/getFlickrImages", to: 'utilities#getFlickrImages'
  get "api/getWeatherData", to: 'utilities#getWeatherData'
  get "api/getReverseGeolocation", to: 'utilities#getReverseGeolocation'
  get "api/getGeolocation", to: 'utilities#getGeolocation'
  
  get 'dashboard/searchform', to: 'dashboard#show_search_form'
  get 'dashboard/deletelocation', to: 'dashboard#show_delete_location'
  get 'dashboard/profile', to: 'dashboard#show_user_profile'
  
  get 'dashboard/addLocation', to: 'dashboard#add_location_to_user'
  get 'dashboard/removeLocation', to: 'dashboard#remove_location'
  
  post 'dashboard/uploadLocationsFile', to: 'dashboard#upload_locations_file'
  
  get 'locations', to: 'locations#get_locations_by_currentuser'
  get 'user/settings', to: 'user#update_settings'
  
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboard#index'
  
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
