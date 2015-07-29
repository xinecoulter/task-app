class UserDecorator < Draper::Decorator
  delegate_all

  def team_result_message(team)
    score = score_in(team)
    opponent_score = team.scores.where.not(id: score).first

    if score.points > opponent_score.points
      status = "won"
    elsif score.points < opponent_score.points
      status = "lost"
    else
      status = "tied"
    end

    "#{status} in this month's chore challenge for #{team.name} in World of WarTask"
  end

end
