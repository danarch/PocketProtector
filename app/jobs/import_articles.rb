require 'alchemyapi'

class ImportArticles < ProgressJob::Base
  def initialize(articles, user_id)
    super progress_max: articles["list"].count
    @articles = articles
    @user_id = user_id
  end

  def perform
    @articles["list"].each do |pocket|
      user = User.find_by_id(@user_id)
      article = user.articles.find_or_create_by(item_id: pocket[1]["item_id"]) do |article|
        article.title = pocket[1]["resolved_title"]
        article.excerpt = pocket[1]["excerpt"]
        article.url = pocket[1]["resolved_url"]
        if pocket[1]["image"]
          article.image = pocket[1]["image"]["src"]
        end
        ##article.text = article.alchemy.text('url', article.url)["text"]
        alchemy_concepts = article.alchemy.concepts('url', article.url)
        if alchemy_concepts['status'] == 'OK'
          update_stage('Tagging Articles')
          alchemy_concepts["concepts"].each do |concept|
            tag = article.concepts.new
            tag.tag = concept["text"]
            tag.save
          end
        else
          update_stage(alchemy_concepts['statusInfo'])
        end
        update_progress
      end
    end
  end

end
