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

    opponent = team.members.where.not(id: self).first.decorate

    "I #{status} against #{opponent.facebook_name} in this month's chore challenge for #{team.name} in World of WarTask!"
  end

  def name
    "#{given_name} #{surname}"
  end

  def facebook_name
    facebook_identity ? "#{facebook_identity.given_name} #{facebook_identity.surname}" : name
  end

end
