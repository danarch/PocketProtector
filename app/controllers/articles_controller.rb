require 'pocket-ruby'


class ArticlesController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :xml, :json


  def retrieve
    Pocket.configure do |config|
      config.consumer_key = ENV["POCKET_APP_ID"]
    end
    client = Pocket.client(:access_token => current_user.token)
    articles = client.retrieve({:state => 'all', :tag => '_untagged_', :contentType => 'article', :sort => 'newest', :detailType => "complete"})
    @job = Delayed::Job.enqueue ImportArticles.new(articles, current_user.id)
  end

  def tag
    Pocket.configure do |config|
      config.consumer_key = ENV["POCKET_APP_ID"]
    end
    client = Pocket.client(:access_token => current_user.token)
    @article = Article.find(params[:id])
    tags = []
    @article.concepts.each do |c|
      tags.append(c.tag)
    end
    client.modify([{:action => "tags_add", :item_id => @article.item_id, :tags => tags.join(", ")}])
    @article.destroy
    redirect_to articles_path
  end

  def edit_concepts
    @article = current_user.articles.find(params[:id])

  end

  def index
    if params[:search]
      @articles = current_user.articles.search_for_articles( params[:search])
    else
      @articles = current_user.articles.includes( :concepts)
    end
  end

  def show
    @article = Article.find(params[:id])
  end

  def edit
    @article = current_user.articles.find(params[:id])
  end

  def update
    @article = current_user.articles.find(params[:id])
    if @article.update(article_params)
      redirect_to @article, notice: 'Your tag has been saved.'
    else
      render 'edit'
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to articles_path
  end

  private

  def article_params
    params.require(:article).permit(:title, :text)
  end
end
