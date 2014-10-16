class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.references :user, index: true
      t.string :item_id
      t.string :title
      t.text :excerpt
      t.string :url

      t.timestamps
    end
  end
end
