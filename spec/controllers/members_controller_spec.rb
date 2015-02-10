require "rails_helper"

describe MembersController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  let(:team) { create(:team, name: "Aniston") }
  before { sign_in user }

  describe "POST 'create'" do
    let(:params) { { member_id: user.id } }
    subject { post :create, team_id: team.id, member: params }

    it "sets the flash" do
      subject
      assert("Challenge accepted! You successfully joined Team #{team.name}." == flash[:notice])
    end

    it "makes the user a member of the team" do
      assert(!team.members.include?(user))
      subject
      assert(team.members.include? user)
    end

    it "saves the new team_membership in the database" do
      expect { subject }.to change(TeamMembership, :count)
    end

    it "redirects to the referring page" do
      subject
      assert_redirected_to teams_path
    end
  end

  describe "DELETE 'destroy'" do
    let!(:membership) { create(:team_membership, team: team, member: user) }
    subject { delete :destroy, team_id: team.id, id: membership.id }

    it "removes the user as a member of the team" do
      assert(team.members.include? user)
      subject
      assert(!team.members.include?(user))
    end

    it "deletes the team_membership from the database" do
      expect{ subject }.to change(TeamMembership, :count).by(-1)
    end

    it "sets the flash" do
      subject
      assert("Aww. Successfully left Team #{team.name}." == flash[:notice])
    end

    it "redirects to the team index" do
      subject
      assert_redirected_to teams_path
    end
  end

end
