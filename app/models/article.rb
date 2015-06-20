class Article < ActiveRecord::Base
  belongs_to :user
  has_many :concepts
  include PgSearch
  pg_search_scope :search_for_articles, :associated_against => {:concepts => :tag}


  def alchemy
    alchemyapi = AlchemyAPI.new()
  end
end
