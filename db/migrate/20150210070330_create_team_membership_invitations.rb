class CreateTeamMembershipInvitations < ActiveRecord::Migration
  def change
    create_table :team_membership_invitations do |t|
      t.integer :user_id
      t.integer :invited_user_id
      t.integer :team_id

      t.timestamps
    end
  end
end
