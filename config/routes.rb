Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  resources :articles
  post '/articles/retrieve' => "articles#retrieve", as: 'retrieve_articles'
  get 'article/:id/tag' => "articles#tag", as: 'tag_article'
  root to: 'welcome#index'
end
