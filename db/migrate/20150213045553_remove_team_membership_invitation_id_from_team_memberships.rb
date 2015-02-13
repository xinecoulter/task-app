class RemoveTeamMembershipInvitationIdFromTeamMemberships < ActiveRecord::Migration
  def change
    remove_column :team_memberships, :team_membership_invitation_id
  end
end
