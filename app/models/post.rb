class Post < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :user
  has_many :reply_messages, class_name: "Message",
                          foreign_key: "reply_post_id",
                          dependent: :destroy
  has_many :senders, through: :reply_messages
  #delegate :gender, :to => :user, :allow_nil => true
  default_scope -> { order(created_at: :desc) }
  VALID_CITY_REGEX = /\A[a-zA-Z\u0080-\u024F\s\/\-\)\(\`\.\"\']+\z/
  VALID_POSTAL_REGEX = /\A+[0-9]+\z/
  validates :user_id, presence: true
  validates :title, presence: true, length: { minimum: 5, maximum: 105}
  validates :city, presence: true, length: { maximum: 45 },
                   format: { with: VALID_CITY_REGEX }
  validates :postal_code, presence: true, format: { with: VALID_POSTAL_REGEX },
            length: { is: 5 }
  validates_date :meeting_date, :on_or_before => lambda { Date.current },
                 :on_or_after => lambda { 5.years.ago },
                 :on_or_after_message => "Meeting Date can not be older than 5 years ago"
  validates :description, presence: true, length: { minimum: 20, maximum: 360}
  validates :gender, presence: true 
  settings index: {
    number_of_shards: 1,
    analysis: {
      filter: {
        snowball: {
          type: 'snowball',
          language: 'French',
        },
        elision: {
          type: 'elision',
          articles: ['l', 'm', 't', 'qu', 'n', 's', 'j', 'd'],
        },
        stopwords: {
          type: 'stop',
          stopwords: '_french_',
          ignore_case: true,
        },
        worddelimiter: {
          type: 'word_delimiter',
        }
      },
      
      analyzer: {
        custom_analyzer: {
                type: 'custom',
                tokenizer: 'standard',
                filter: ['stopwords', 'asciifolding', 'lowercase', 'snowball', 'elision', 'worddelimiter'],
                # filter: ['asciifolding'],
        }
      }
    }
  } do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'custom_analyzer', index_options: 'offsets'
      indexes :description, analyzer: 'custom_analyzer', index_options: 'offsets'
      indexes :city, analyzer: 'custom_analyzer'
      indexes :postal_code
      indexes :gender, index: 'not_analyzed'
      indexes :created_at, type: 'date', format: 'dateOptionalTime', index: 'not_analyzed'
    end
  end
  
  def as_indexed_json(options={})
      as_json(only: ['id', 'title', 'description', 'city', 'postal_code', 'created_at', 'gender'])
  end
  
  def self.female_search(query)
  __elasticsearch__.search(
    {
      query: {
        filtered: {
          filter:  { 
            term:  {
              gender: "M"
            }
          },
          query: {
            multi_match: {
              query: query,
              fields: ['title', 'description', 'city', 'postal_code']
            }
          }
        }
      },
      sort: [
        { 
         created_at: { 
          unmapped_type: 'long',
          order: 'desc'
         } 
        }
      ]
    }
  )
  end
  
  def self.male_search(query)
  __elasticsearch__.search(
    {
      query: {
        filtered: {
          filter:  { 
            term:  {
              gender: "F"
            }
          },
          query: {
            multi_match: {
              query: query,
              fields: ['title', 'description', 'city', 'postal_code']
            }
          }
        }
      },
      sort: [
        { 
         created_at: { 
          unmapped_type: 'long',
          order: 'desc'
         } 
        }
      ]
    }
  )
  end

  
end

Post.__elasticsearch__.create_index! force: true
Post.import

# Post.mappings.to_hash

# Post.settings.to_hash


# # Delete the previous articles index in Elasticsearch
# Post.__elasticsearch__.client.indices.delete index: Post.index_name rescue nil

# # Create the new index with the new mapping
# Post.__elasticsearch__.client.indices.create \
#   index: Post.index_name,
#   body: { settings: Post.settings.to_hash, mappings: Post.mappings.to_hash }

# Post.import
