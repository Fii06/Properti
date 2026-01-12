Rails.application.routes.draw do
  devise_for :users

  # Health check bawaan Rails
  get "up" => "rails/health#show", as: :rails_health_check

  resources :propertis do
    resources :riwayat_hargas, only: [:index, :new, :create, :destroy]
    resources :analisis_hargas, only: [:index, :new, :create, :destroy] 
  end  
  get "/about", to: "pages#about"
  get "/contact", to: "pages#contact"
  get "/faq", to: "pages#faq"
  get "/privacy", to: "pages#privacy"
  get "/terms", to: "pages#terms"
  get "/listings", to: "pages#listings"
  # get "/listings/:id", to: "pages#listing_detail", as: :listing
  get "/home", to: "pages#home"
  get "/about", to: "pages#about"
  get "/agents", to: "pages#agents"
  get "/services", to: "pages#services"
  get "/blog", to: "pages#blog", as: :blog
  get "/neighborhoods", to: "pages#neighborhoods"
  get "/images/:id", to: "images#show", as: :grid_image

  post "/services/preview", to: "propertis#preview", as: :preview_property
  post "/services/create", to: "propertis#create",  as: :create_property
  

  get  "/services", to: "propertis#new"
  post "/listings", to: "propertis#create"
  get  "/listings/:id", to: "propertis#show", as: :listing

  post "/sale_requests", to: "sale_requests#create"
  resources :sale_requests, only: [:new, :create]
  resources :propertis
  resources :agents
  resources :posts
  resources :neighborhoods

  resources :fasilitas, only: [:index, :new, :create, :edit, :update, :destroy]

  get 'home', to: 'pages#home'
  root 'pages#home'

end