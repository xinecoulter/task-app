Rails.application.routes.draw do
  devise_for :users, skip: [:sessions]

  authenticated :user do
    root to: "dashboard#show", as: :authenticated_root
  end

  as :user do
    root to: 'devise/sessions#new'
    post '/' => 'devise/sessions#create', as: :user_session
    delete 'signout' => 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :tasks, except: :show

  resources :teams do
    resources :members, only: [:create, :destroy]
    resources :team_membership_invitations, only: [:index, :create, :destroy]
    resources :scores, only: :update
  end
end
