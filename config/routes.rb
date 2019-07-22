Rails.application.routes.draw do
  resources :queries

  resources :collections do
    member do
      get 'remove'
    end
  end

  post 'save' => 'collections#save'
  get 'export' => 'collections#export'

  devise_for :users, :path_prefix => 'my'
  #, separates devise and custom admin crud

  root 'home#index'
  ###=> documents#search

  resources :user_tickets do
    member do
      get 'claim'
      get 'resolve'
    end
  end
  resources :users

  #where the magic happens
  resources :documents do
    member do
      get 'language_parse'
      get 'resection_document'
    end
    #this code points to sections, a subclass of documents and adds the extra routes to the resource generation
    resources :sections

    member do
      get 'edit_section_separation'
      post 'update_section_separation'
    end
  end

  get 'advanced' => 'documents#advanced_search'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
