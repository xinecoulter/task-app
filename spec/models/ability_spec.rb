require "rails_helper"
require "cancan/matchers"

describe Ability do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  subject(:ability) { Ability.new(user) }

  describe "tasks" do
    it "can create and update a task it owns" do
      task = build(:task, user: user)
      expect(ability).to be_able_to(:create, task)
      expect(ability).to be_able_to(:update, task)
    end
    it "can update the task of a user who is a teammate" do
      team = create(:team)
      task = build(:task, user: other_user)
      team.members << user << other_user
      expect(ability).to be_able_to(:update, task)
    end
    it "cannot update the task of a user who is not a teammate" do
      team = create(:team)
      task = build(:task, user: other_user)
      team.members << user
      expect(ability).to_not be_able_to(:update, task)
    end
    it "can view_edit a task it owns" do
      task = build(:task, user: user)
      expect(ability).to be_able_to(:view_edit, task)
    end
    it "cannot view_edit a task it does not own" do
      task = build(:task, user: other_user)
      expect(ability).to_not be_able_to(:view_edit, task)
    end
    it "can destroy a task it owns" do
      task = build(:task, user: user)
      expect(ability).to be_able_to(:destroy, task)
    end
    it "cannot destroy a task it does not own" do
      task = build(:task, user: other_user)
      expect(ability).to_not be_able_to(:destroy, task)
    end
  end

  describe "teams" do
    it "can create a team" do
      team = build(:team)
      expect(ability).to be_able_to(:create, team)
    end
    it "can manage a team it owns" do
      team = build(:team)
      user.add_role :owner, team
      expect(ability).to be_able_to(:manage, team)
    end
    it "can't manage a team it doesn't own" do
      team = build(:team)
      expect(ability).to_not be_able_to(:manage, team)
    end
    it "can read a team it is a member of" do
      team = create(:team)
      team.members << user
      expect(ability).to be_able_to(:read, team)
    end
    it "cannot read a team it is not a member of" do
      team = create(:team)
      expect(ability).to_not be_able_to(:read, team)
    end
  end

  describe "team_membership_invitations" do
    it "can create a team_membership_invitation to a team it owns" do
      invitation = build(:team_membership_invitation)
      user.add_role :owner, invitation.team
      expect(ability).to be_able_to(:create, invitation)
    end
    it "can destroy a team_membership_invitation to a team it owns" do
      invitation = build(:team_membership_invitation)
      user.add_role :owner, invitation.team
      expect(ability).to be_able_to(:destroy, invitation)
    end
    it "cannot create a team_membership_invitation to a team it does not own" do
      invitation = build(:team_membership_invitation)
      expect(ability).to_not be_able_to(:create, invitation)
    end
    it "cannot destroy a team_membership_invitation to a team it does not own" do
      invitation = build(:team_membership_invitation)
      expect(ability).to_not be_able_to(:destroy, invitation)
    end
    it "cannot create a team_membership_invitation to a team if the team is full" do
      team = create(:team)
      team.members << user << other_user
      invitation = build(:team_membership_invitation, team: team)
      user.add_role :owner, invitation.team
      expect(ability).to_not be_able_to(:create, invitation)
    end
  end

  describe "team_memberships" do
    it "can create a team_membership to a team if it is the invited_user of a team_membership_invitation to the team (other requirements met)" do
      team = create(:team)
      invitation = create(:team_membership_invitation, invited_user: user, team: team)
      membership = build(:team_membership, member: user, team: team)
      expect(ability).to be_able_to(:create, membership)
    end
    it "cannot create a team_membership to a team if it is not the invited_user of a team_membership_invitation to the team" do
      team = create(:team)
      membership = build(:team_membership, member: user, team: team)
      expect(ability).to_not be_able_to(:create, membership)
    end
    it "can destroy a team_membership if it is the member of the team_membership" do
      membership = create(:team_membership, member: user)
      expect(ability).to be_able_to(:destroy, membership)
    end
    it "cannot destroy a team_membership it is not the member of the team_membership" do
      membership = create(:team_membership)
      expect(ability).to_not be_able_to(:destroy, membership)
    end
    it "cannot destroy a team_membership if it is the owner of the team" do
      team = create(:team)
      user.add_role(:owner, team)
      membership = create(:team_membership, member: user, team: team)
      expect(ability).to_not be_able_to(:destroy, membership)
    end
  end

  describe "identities" do
    it "can destroy an identity it owns" do
      identity = build(:identity, user: user)
      expect(ability).to be_able_to(:destroy, identity)
    end

    it "cannot destroy an identity that it does not own" do
      identity = build(:identity, user: other_user)
      expect(ability).to_not be_able_to(:destroy, identity)
    end
  end
end
