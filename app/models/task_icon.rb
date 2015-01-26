class TaskIcon < ActiveRecord::Base
  has_many :tasks, foreign_key: :task_icon_id

  validates_presence_of :file_name
end
