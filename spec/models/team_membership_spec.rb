require "rails_helper"

describe TeamMembership do
  let(:user) { create(:user) }
  let(:team) { create(:team) }

  it "can be created" do
    team_membership = build(:team_membership)
    team_membership.save!
    expect(team_membership).to be_persisted
    expect(team_membership.class).to eq(TeamMembership)
  end

  it "is unique for a given member and team" do
    create(:team_membership, member: user, team: team)
    duplicate = build(:team_membership, member: user, team: team)
    assert(duplicate.invalid?)
  end
end
