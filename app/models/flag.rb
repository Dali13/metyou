class Flag < ActiveRecord::Base
  belongs_to :flaged, class_name: "Post"
  validates :flaged_id, presence: true
  validates :flager_id, presence: true
  validates :flag_message, presence: true, length: { minimum: 5, maximum: 300}
  attr_accessor :verification
end
