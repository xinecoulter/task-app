class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :member, class_name: "User"

  validates_uniqueness_of :member_id, scope: :team_id

  def self.make(user_id, team_id)
    membership = TeamMembership.new(member_id: user_id, team_id: team_id)
    membership.save
    membership
  end
end
