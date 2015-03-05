# == Schema Information
#
# Table name: shortened_urls
#
#  id         :integer          not null, primary key
#  short_url  :string           not null
#  long_url   :string           not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class ShortenedUrl < ActiveRecord::Base
  validates :short_url, uniqueness: true, presence: true
  validates :long_url, presence: true, length: { maximum: 1024 }
  validates :user_id, presence: true

  belongs_to(
    :submitter,
    class_name: :User,
    foreign_key: :user_id,
    primary_key: :id
  )

  has_many(
    :visits,
    class_name: :Visit,
    foreign_key: :shortened_url_id,
    primary_key: :id
  )

  has_many(
    :taggings,
    class_name: :Tagging,
    foreign_key: :shortened_url_id,
    primary_key: :id
  )

  has_many :visitors, -> { distinct }, through: :visits, source: :visitor
  has_many :tag_topics, -> {distinct }, through: :taggings, source: :tag_topic

  def self.random_code
    temp_code = SecureRandom.urlsafe_base64(16)
    until !ShortenedUrl.exists?(short_url: temp_code)
      temp_code = SecureRandom.urlsafe_base64(16)
    end

    temp_code
  end

  def self.create_for_user_and_long_url(user, long_url)
    unless spam?(user)
      ShortenedUrl.create!(short_url: random_code, long_url: long_url, user_id: user.id)
    else
      raise "you are a spammer!"
    end
  end

  def num_clicks
    visits.length
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visits.select(:user_id).where('created_at > ?', 10.minutes.ago).distinct.count
  end

  def self.spam?(user)
    ShortenedUrl.where(user_id: user.id).where('created_at > ?', 1.minute.ago).length >= 5
  end
end
