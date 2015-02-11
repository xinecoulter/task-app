require "rails_helper"

describe TeamMembershipInvitation do
  let(:user) { create(:user) }
  let(:invited_user) { create(:user) }
  let(:team) { create(:team) }

  it "can be created" do
    invitation = build(:team_membership_invitation)
    invitation.save!
    expect(invitation).to be_persisted
    expect(invitation.class).to eq(TeamMembershipInvitation)
  end

  it "is unique for a given invited_user, user, and team" do
    create(:team_membership_invitation, invited_user: invited_user, user: user, team: team)
    duplicate = build(:team_membership_invitation, invited_user: invited_user, user: user, team: team)
    assert(duplicate.invalid?)
  end
end
