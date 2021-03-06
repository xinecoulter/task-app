class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :task_icon

  INTERVAL_TYPES = %w[day week month]

  validates_presence_of :name
  validates_presence_of :interval
  validates_presence_of :interval_number
  validates_presence_of :estimated_effort
  validates_presence_of :point_value
  validates_inclusion_of :interval_type, in: INTERVAL_TYPES

  default_scope { order("created_at ASC") }

  def self.make(user_id, params)
    task = new(params)
    task.user_id = user_id
    task.interval = task.calculate_interval
    task.point_value = task.calculate_point_worth
    task.save
    task
  end

  def self.find_and_update(id, params)
    task = find(id)

    if params[:interval_number] && params[:interval_type]
      options = { new_interval_number: params[:interval_number].to_i, new_interval_type: params[:interval_type] }
      params[:interval] = task.calculate_interval(options)
    end

    if params[:estimated_effort]
      params[:point_value] = task.calculate_point_worth(params[:estimated_effort].to_i)
    end

    if params[:last_completed_at]
      transaction do
        Score.where(member_id: task.user_id).each do |score|
          Score.find_and_update(score.id, task.point_value)
        end
        task.update(params)
      end
    else
      task.update(params)
    end

    task
  end

  def calculate_interval(options={})
    int_type = options[:new_interval_type] ? options[:new_interval_type] : interval_type
    int_number = options[:new_interval_number] ? options[:new_interval_number] : interval_number
    case int_type
    when "day"
      seconds_multiplier = 86400 # 1 day (24 hrs * 60 min * 60 sec)
    when "week"
      seconds_multiplier = 604800 # 1 week (7 days * 24 hrs * 60 min * 60 sec)
    when "month"
      seconds_multiplier = 2592000 # 30 days (30 days * 24 hrs * 60 min * 60 sec)
    end
    int_number * seconds_multiplier
  end

  def task_due
    if last_completed_at.nil?
      DateTime.now
    else
      last_completed_at + interval
    end
  end

  def ready_for_completion?
    return true if last_completed_at.nil?
    DateTime.now >= task_due
  end

  def calculate_point_worth(new_estimated_effort=nil)
    effort = new_estimated_effort ? new_estimated_effort : estimated_effort
    if effort <= 15
      1
    elsif effort >= 30
      5
    else
      2
    end
  end
end
