# == Schema Information
#
# Table name: tag_topics
#
#  id    :integer          not null, primary key
#  topic :string           not null
#

class TagTopic < ActiveRecord::Base
  has_many(
    :taggings,
    class_name: :Tagging,
    foreign_key: :tag_topic_id,
    primary_key: :id
  )

  has_many :shortened_urls, -> { distinct }, through: :taggings, source: :shortened_url

  def most_popular_links(n)
    shortened_urls.group("shortened_urls.id").order('COUNT(taggings.shortened_url_id)').limit(n)
  end

end
