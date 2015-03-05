class AddTagTopics < ActiveRecord::Migration
  def change
    create_table :tag_topics do |t|
      t.string :topic, null: false

      t.timestamp
    end
  end
end
