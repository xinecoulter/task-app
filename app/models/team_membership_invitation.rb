class TeamMembershipInvitation < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :invited_user, class_name: "User", touch: true
  belongs_to :team
  has_one :team_membership

  validates_uniqueness_of :invited_user_id, scope: [:user_id, :team_id]

  def self.make(user, invited_user, team)
    invitation = TeamMembershipInvitation.create(user: user, invited_user: invited_user, team: team)
    invitation
  end
end
