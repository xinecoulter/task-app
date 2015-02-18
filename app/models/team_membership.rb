class TeamMembership < ActiveRecord::Base
  belongs_to :team, touch: true
  belongs_to :member, class_name: "User", touch: true

  validates_uniqueness_of :member_id, scope: :team_id

  def self.make(user_id, team_id)
    membership = TeamMembership.new(member_id: user_id, team_id: team_id)
    membership.save
    Score.make(user_id, team_id)
    membership
  end
end
