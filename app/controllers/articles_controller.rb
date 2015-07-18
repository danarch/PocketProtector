require 'pocket-ruby'
require 'alchemyapi'


class ArticlesController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :xml, :json


  def retrieve
    Pocket.configure do |config|
      config.consumer_key = ENV["POCKET_APP_ID"]
    end
    client = Pocket.client(:access_token => current_user.token)
    articles = client.retrieve({:state => 'all', :tag => '_untagged_', :contentType => 'article', :sort => 'newest', :detailType => "complete"})
    articles["list"].each do |pocket|
      article = current_user.articles.find_or_create_by(item_id: pocket[1]["item_id"]) do |article|
        article.title = pocket[1]["resolved_title"]
        article.excerpt = pocket[1]["excerpt"]
        article.url = pocket[1]["resolved_url"]
        if pocket[1]["image"]
          article.image = pocket[1]["image"]["src"]
        end
        ##article.text = article.alchemy.text('url', article.url)["text"]
        article.alchemy.concepts('url', article.url)["concepts"].each do |concept|
          tag = article.concepts.new
          tag.tag = concept["text"]
          tag.save
        end
      end
    end
    redirect_to articles_path
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
