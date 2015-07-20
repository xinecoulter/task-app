require "rails_helper"

describe User do
  let(:user) { create(:user) }

  it "can be created" do
    user = build(:user)
    user.save!
    expect(user).to be_persisted
    expect(user.class).to eq(User)
  end

  it "must have an email" do
    assert(build(:user, email: "christine@example.com").valid?)
    assert(build(:user, email: nil).invalid?)
  end

  it "must have an email with the correct format" do
    valid = ["thor@thor.thor", "thor.thor@thor.thor", "thor@thor.thor.thor", "thor+thor@thor.thor"]
    invalid = ["@loki.loki", "loki@", "loki@loki", "loki@loki,loki", "loki@loki,loki.loki", "loki @loki.loki"]
    invalid.each { |e| assert build(:user, email: e).invalid? }
    valid.each   { |e| assert build(:user, email: e).valid? }
  end

  it "cannot have the same email as another user (PG level)" do
    user1 = create(:user, email: "christine@example.com")
    user2 = create(:user, email: "christine2@example.com")
    assert(build(:user, email: "christine@example.com").invalid?)
    expect { user2.update!(email: "christine@example.com") }.to raise_error
  end

  describe "#membership_in" do
    let(:team) { create(:team) }
    subject { user.membership_in(team) }
    context "when the user has a team_membership in a team" do
      let!(:team_membership) { create(:team_membership, member: user, team: team) }
      it "is the team_membership" do
        assert(team_membership == subject)
      end
    end
    context "when the user has no team_membership in a team" do
      it "is nil" do
        assert(subject.nil?)
      end
    end
  end

  describe "#membership_id" do
    let(:team) { create(:team) }
    subject { user.membership_id(team) }

    context "when the user has a team_membership in a team" do
      let!(:membership) { create(:team_membership, member: user, team: team) }

      it "is the id of the team_membership" do
        assert(membership.id == subject)
      end
    end

    context "when the user has no team_membership in a team" do
      it "is nil" do
        assert(subject.nil?)
      end
    end
  end

  describe "#team_membership_invitations_to" do
    let(:other_user) { create(:user) }
    let(:team) { create(:team) }
    let!(:invitation) { create(:team_membership_invitation, user: user, invited_user: other_user, team: team) }
    subject { user.team_membership_invitations_to(team) }

    it "returns the user's outgoing_team_membership_invitations to a team" do
      assert([invitation] == subject)
    end
  end

  describe "#team_membership_invitation_from" do
    let(:other_user) { create(:user) }
    let(:team) { create(:team) }
    subject { user.team_membership_invitation_from(team) }

    context "when the user is the invited_user of a team_membership_invitation from a given team" do
      let!(:invitation) { create(:team_membership_invitation, user: other_user, invited_user: user, team: team) }

      it "returns the team_membership_invitation" do
        assert(invitation == subject)
      end
    end

    context "when the user does not have a team_membership_invitation from a given team" do
      it "is nil" do
        assert(subject.nil?)
      end
    end
  end

  describe "#invited_to?" do
    let(:other_user) { create(:user) }
    let(:team) { create(:team) }
    subject { user.invited_to?(team) }

    context "when the user is the invited_user of a team_membership_invitation from a given team" do
      let!(:invitation) { create(:team_membership_invitation, user: other_user, invited_user: user, team: team) }

      it { should be_truthy }
    end

    context "when the user does not have a team_membership_invitation from a given team" do
      it { should be_falsey }
    end
  end

  describe "#teammates_with?" do
    let(:other_user) { create(:user) }
    let(:team) { create(:team) }
    before { team.members << user }
    subject { user.teammates_with?(other_user) }

    context "when the user is the member of a team that has the specified user as a member" do
      before { team.members << other_user }

      it { should be_truthy }
    end

    context "when the user is not a member of a team that has the specified user as a member" do
      it { should be_falsey }
    end
  end

  describe "#score_in" do
    let(:team) { create(:team) }
    before { team.members << user }
    subject { user.score_in(team) }

    context "when the user has a score in a team" do
      let!(:score) { create(:score, member: user, team: team) }
      it "is the score" do
        assert(score == subject)
      end
    end
    context "when the user has no score in a team" do
      it "is nil" do
        assert(subject.nil?)
      end
    end
  end

  describe "#add_identity" do
    let(:name) { "instagraph" }
    let(:uid) { "24601" }
    let(:token) { "token" }
    let(:credentials) { double(token: token) }
    let(:auth) { double(provider: name, uid: uid, credentials: credentials ) }
    subject { user.add_identity(auth) }

    it "returns the identity that matches the auth hash" do
      response = subject
      assert(name == response.name)
      assert(uid == response.uid)
    end

    it "does not persist changes to the identity if assigning the identity to the user blows up" do
      user.identities.stub(:<<).and_raise(StandardError)
      expect { subject rescue StandardError }.to_not change(Identity, :count)
    end

    context "when the user's identities include the identity" do
      let!(:identity) { create(:identity, name: name, uid: uid) }
      before { user.identities << identity }

      it "does not do anything" do
        assert(user.identities.include? identity)
        subject
        assert(user.identities.include? identity)
      end
    end

    context "when the user's identities do not include the identity" do
      let!(:identity) { create(:identity, name: name, uid: uid) }

      it "assigns the identity to the user" do
        assert(!user.identities.include?(identity))
        subject
        assert(user.identities.include? identity)
      end
    end
  end
end
