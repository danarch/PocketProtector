require 'pocket_api'

class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    PocketApi.configure(:client_key => ENV["POCKET_APP_ID"], :access_token => current_user.token)
    articles = PocketApi.retrieve({:state => 'all', :tag => '_untagged_', :contentType => 'article', :detailType => "complete"})
    articles.each do |pocket|
      article = current_user.articles.new
      article.item_id = pocket[1]["item_id"]
      article.title = pocket[1]["resolved_title"]
      article.excerpt = pocket[1]["excerpt"]
      article.url = pocket[1]["resolved_url"]
      article.save
    end
    @articles = current_user.articles
  end
end
