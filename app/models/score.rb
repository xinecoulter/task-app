class Score < ActiveRecord::Base
  belongs_to :team, touch: true
  belongs_to :member, class_name: "User", touch: true

  validates_uniqueness_of :member_id, scope: :team_id

  def self.make(user_id, team_id)
    score = Score.create(member_id: user_id, team_id: team_id)
    score
  end

  def self.find_and_update(id, points)
    score = find(id)
    score.update(points: score.points + points) if score.team.is_full?
    score
  end

end
