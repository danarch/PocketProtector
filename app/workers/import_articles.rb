class ImportArticles
  include Sidekiq::Worker

  def perform(articles, count)
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
  end
end
