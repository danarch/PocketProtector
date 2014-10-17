require 'pocket_api'
require 'alchemyapi'


class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def index
    PocketApi.configure(:client_key => ENV["POCKET_APP_ID"], :access_token => current_user.token)
    articles = PocketApi.retrieve({:state => 'all', :tag => '_untagged_', :contentType => 'article', :detailType => "complete"})
    articles.each do |pocket|
      article = current_user.articles.find_or_create_by(item_id: pocket[1]["item_id"]) do
        article.title = pocket[1]["resolved_title"]
        article.excerpt = pocket[1]["excerpt"]
        article.url = pocket[1]["resolved_url"]
        article.alchemy.concepts('url', article.url)["concepts"].each do |concept|
          tag = article.concepts.new
          tag.tag = concept["text"]
          tag.save
        end
      end
    end

    @articles = current_user.articles.includes( :concepts)
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
      redirect_to @article, notice: 'Your discussion has been saved.'
    else
      render 'edit'
    end
  end

  def vote
    @article = Article.find(params[:id])
    current_user.votes.create! article: @article
    redirect_to :back
  end

  def unvote
    @article = Article.find(params[:id])
    @vote = current_user.votes.find(@article)
    @vote.destroy
    redirect_to @article
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
