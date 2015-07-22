class UserDecorator < Draper::Decorator
  delegate_all

  def team_result_message(team)
    score = score_in(team)
    other_score_points = team.scores.where.not(id: score).pluck(:points)
    lower_score_points = other_score_points.select { |points| score.points > points }
    higher_score_points = other_score_points.select { |points| score.points < points }

    if lower_score_points.count == other_score_points.count
      status = "won"
    elsif higher_score_points.any?
      status = "lost"
    else
      status = "tied"
    end

    "#{status} in this month's chore challenge for #{team.name} in World of WarTask"
  end

end
