class CreateConcepts < ActiveRecord::Migration
  def change
    create_table :concepts do |t|
      t.string :tag
      t.references :article, index: true

      t.timestamps
    end
  end
end
