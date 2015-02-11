class TeamMembershipInvitation < ActiveRecord::Base
  validates_uniqueness_of :invited_user_id, scope: [:user_id, :team_id]
end
