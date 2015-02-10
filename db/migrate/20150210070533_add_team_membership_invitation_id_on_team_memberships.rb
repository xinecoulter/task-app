class AddTeamMembershipInvitationIdOnTeamMemberships < ActiveRecord::Migration
  def change
    add_column :team_memberships, :team_membership_invitation_id, :integer
  end
end
