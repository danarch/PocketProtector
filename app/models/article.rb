class Article < ActiveRecord::Base
  belongs_to :user
  has_many :concepts
  has_many :comments, dependent: :destroy
  has_many :votes

  def alchemy
    alchemyapi = AlchemyAPI.new()
  end
end
