class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :task_icon

  INTERVAL_TYPES = %w[day week month]

  validates_presence_of :name
  validates_presence_of :interval
  validates_presence_of :interval_number
  validates_presence_of :estimated_effort
  validates_inclusion_of :interval_type, in: INTERVAL_TYPES

  default_scope { order("created_at ASC") }

  def self.make(user_id, params)
    task = new(params)
    task.user_id = user_id
    task.interval = calculate_interval(params[:interval_number].to_i, params[:interval_type])
    task.point_value = task.calculate_point_worth
    task.save
    task
  end

  def self.find_and_update(id, params)
    task = find(id)

    if params[:interval_number] && params[:interval_type]
      params[:interval] = calculate_interval(params[:interval_number].to_i, params[:interval_type])
    end

    if params[:last_completed_at]
      points = task.calculate_points_to_award(params[:last_completed_at].to_datetime)
      transaction do
        Score.where(member_id: task.user_id).each do |score|
          Score.find_and_update(score.id, points)
        end
        task.update(params)
      end
    else
      task.update(params)
    end

    task
  end

  def self.calculate_interval(interval_number, interval_type)
    case interval_type
    when "day"
      seconds_multiplier = 86400 # 1 day (24 hrs * 60 min * 60 sec)
    when "week"
      seconds_multiplier = 604800 # 1 week (7 days * 24 hrs * 60 min * 60 sec)
    when "month"
      seconds_multiplier = 2592000 # 30 days (30 days * 24 hrs * 60 min * 60 sec)
    end
    interval_number * seconds_multiplier
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

  def calculate_points_to_award(new_date_time)
    return 2 if new_date_time > (task_due - 86400)

    ((task_due - new_date_time) / 86400).to_i * 2
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
