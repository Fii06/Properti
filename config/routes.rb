Rails.application.routes.draw do
  devise_for :users

  # Health check bawaan Rails
  get "up" => "rails/health#show", as: :rails_health_check

  resources :propertis do
    resources :riwayat_hargas, only: [:index, :new, :create, :destroy]
    resources :analisis_hargas, only: [:index, :new, :create, :destroy] 
  end  

  resources :fasilitas, only: [:index, :new, :create, :edit, :update, :destroy]

  get 'home', to: 'pages#home'
  root 'pages#home'

end
