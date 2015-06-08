Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  resources :articles do
    resources :comments
    member do
      patch :vote
      patch :unvote
    end
  end
  root to: 'welcome#index'
end
