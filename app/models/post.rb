class Post < ActiveRecord::Base
  belongs_to :user
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
                   

  
end
