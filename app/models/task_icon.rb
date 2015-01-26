class TaskIcon < ActiveRecord::Base
  validates_presence_of :file_name
end
