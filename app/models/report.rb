class Report < ActiveRecord::Base
  belongs_to :reported, class_name: "User"
  validates :reported_id, presence: true
  validates :reporter_id, presence: true
  validates :report_message, presence: true, length: { minimum: 5, maximum: 300}
  attr_accessor :verification
  
end
