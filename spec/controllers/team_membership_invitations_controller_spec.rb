require "rails_helper"

describe TeamMembershipInvitationsController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:team) { create(:team) }
  before do
    user.add_role(:owner, team)
    sign_in user
  end

  describe "GET 'index'" do
    before { TeamMembershipInvitation.make(user, other_user, team) }
    subject { get :index, team_id: team.id }

    it "checks authorization" do
      new_invitation = build(:team_membership_invitation)
      TeamMembershipInvitation.stub(:new) { new_invitation }
      controller.should_receive(:authorize!).with(:create, new_invitation)
      subject
    end

    it "stores the team as @team" do
      subject
      assert(team == assigns(:team))
    end

    it "stores the user's outgoing_team_membership_invitations for the team as @invitations" do
      subject
      assert(user.outgoing_team_membership_invitations.where(team: team) == assigns(:invitations))
    end

    it "renders the :index template" do
      subject
      expect(response).to render_template :index
    end
  end

  describe "POST 'create'" do
    let(:params) { { invited_user_email: other_user.email } }
    let(:the_invitation) { create(:team_membership_invitation, user: user, invited_user: other_user, team: team) }
    subject { post :create, team_id: team.id, team_membership_invitation: params }

    it "checks authorization" do
      TeamMembershipInvitation.stub(:make) { the_invitation }
      controller.should_receive(:authorize!).with(:create, the_invitation)
      subject
    end

    it "redirects to the team_membership_invitations index" do
      subject
      assert_redirected_to team_team_membership_invitations_path(team)
    end

    context "with valid attributes" do
      it "saves the new team_membership_invitation in the database" do
        expect { subject }.to change(TeamMembershipInvitation, :count).by(1)
      end

      it "sets the flash" do
        subject
        assert("Awesomesauce! Successfully invited #{other_user.email}." == flash[:notice])
      end
    end

    context "with invalid attributes" do
      context "where invited_user_email does not belong to anyone in the database" do
        let(:params) { { invited_user_email: "other_user.email" } }
        it "does not save the new team_membership_invitation in the database" do
          expect { subject }.to_not change(TeamMembershipInvitation, :count)
        end

        it "sets the flash" do
          subject
          assert("Do not pass Go. Do not collect $200. JK, change something and try it again." == flash[:error])
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    let!(:invitation) { create(:team_membership_invitation, user: user, invited_user: other_user, team: team) }
    subject { delete :destroy, team_id: team.id, id: invitation.id }

    it "checks authorization before deleting the team_membership_invitation" do
      controller.should_receive(:authorize!).with(:destroy, invitation)
      subject
    end

    it "destroys the team_membership_invitation" do
      expect { subject }.to change(TeamMembershipInvitation, :count).by(-1)
    end

    it "sets the flash" do
      subject
      assert("Cool beans. Successfully uninvited #{other_user.email}." == flash[:notice])
    end

    it "redirects to the team_membership_invitations index" do
      subject
      assert_redirected_to team_team_membership_invitations_path(team)
    end
  end
end
