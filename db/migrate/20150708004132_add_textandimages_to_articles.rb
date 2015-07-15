class AddTextandimagesToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :text, :text
    add_column :articles, :image, :text
  end
end
