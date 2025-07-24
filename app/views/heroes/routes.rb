Rails.application.routes.draw do
  resources :heroes do
    collection do
      post :import_from_api
    end
  end
  
  get 'about', to: 'pages#about'


  get 'roles', to: 'roles#index', as: :roles
 
  root "heroes#index"
  

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

 
end
