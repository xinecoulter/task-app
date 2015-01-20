Rails.application.routes.draw do
  devise_for :users, skip: [:sessions]

  authenticated :user do
    root to: "dashboard#show", as: :authenticated_root
  end

  as :user do
    root to: 'devise/sessions#new', as: :new_user_session
    post '/' => 'devise/sessions#create', as: :user_session
    delete 'signout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
end
