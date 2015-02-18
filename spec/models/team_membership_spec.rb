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

  describe ".make" do
    subject { TeamMembership.make(user.id, team.id) }

    it "makes a new team_membership with the provided params" do
      membership = subject
      assert(membership.class == TeamMembership)
      assert(membership.persisted?)
      assert(team == membership.team)
      assert(user == membership.member)
    end

    it "saves the new team_membership in the database" do
      expect { subject }.to change(TeamMembership, :count).by(1)
    end

    it "sends a message to Score.make" do
      Score.should_receive(:make).with(user.id, team.id)
      subject
    end
  end
end
