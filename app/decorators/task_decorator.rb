class TaskDecorator < Draper::Decorator
  delegate_all

  def interval_description
    if 1 == interval_number && "day" == interval_type
      "daily"
    elsif 1 == interval_number
      "#{interval_type}ly"
    else
      "every #{interval_number} #{interval_type}s"
    end
  end

end
