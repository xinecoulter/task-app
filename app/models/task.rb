class Task < ActiveRecord::Base
  belongs_to :user

  attr_accessor :interval_number, :interval_type

  def self.make(user_id, params)
    task = Task.new(params)
    task.user_id = user_id
    task.save
    task
  end
end
