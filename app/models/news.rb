class News
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title,      type: String
  field :url,        type: String
  field :image,      type: String
  field :excerpt,    type: String
  field :content,    type: String
  field :source,     type: String
  field :posted_at,  type: String

  index({ url: 1 }, { unique: true })
end
