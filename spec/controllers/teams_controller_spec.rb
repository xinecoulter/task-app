require "rails_helper"

describe TeamsController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET 'index'" do
    let(:team1) { create(:team) }
    let(:team2) { create(:team) }
    let(:team3) { create(:team) }
    let(:other_user) { create(:user) }
    before do
      team1.members << user
      team2.members << user
      TeamMembershipInvitation.make(other_user, user, team3)
    end
    subject { get :index }

    it "assigns the user's teams to @teams" do
      subject
      assert(user.teams == assigns[:teams])
    end

    it "assigns the user's incoming_team_membership_invitations to @invitations" do
      subject
      assert(user.incoming_team_membership_invitations == assigns[:invitations])
    end

    it "renders the :index template" do
      subject
      expect(response).to render_template :index
    end
  end

  describe "GET 'new'" do
    subject { get :new }

    it "checks authorization" do
      new_team = build(:team)
      Team.stub(:new) { new_team }
      controller.should_receive(:authorize!).with(:create, new_team)
      subject
    end

    it "renders the :new template" do
      subject
      expect(response).to render_template :new
    end
  end

  describe "POST 'create'" do
    let(:the_team) { create(:team) }
    let(:name) { "Guardians of the Galaxy" }
    let(:params) { { name: name } }
    subject { post :create, team: params }

    it "checks authorization" do
      Team.stub(:make) { the_team }
      controller.should_receive(:authorize!).with(:create, the_team)
      subject
    end

    context "with valid attributes" do
      it "saves the new team in the database" do
        expect { subject }.to change(Team, :count).by(1)
      end

      it "sets the flash" do
        subject
        assert("Awesomesauce! Team #{name} successfully created." == flash[:notice])
      end

      it "redirects to the team" do
        subject
        assert_redirected_to team_path(assigns[:team])
      end
    end

    context "with invalid attributes" do
      let(:name) { "" }

      it "does not save the new team in the database" do
        expect { subject }.to_not change(Team, :count)
      end

      it "sets the flash" do
        subject
        assert("Do not pass Go. Do not collect $200. JK, change something and try it again." == flash[:error])
      end

      it "re-renders the :new template" do
        subject
        expect(response).to render_template :new
      end
    end
  end

  describe "GET 'show'" do
    let(:team) { create(:team) }
    let(:user2) { create(:user) }
    before do
      user.add_role :owner, team
      team.members << user
      team.members << user2
    end
    subject { get :show, id: team.id }

    it "assigns the requested team to @team" do
      subject
      assert(team == assigns(:team))
    end

    it "assigns the first team member to @member_1" do
      subject
      assert(user == assigns(:member_1))
    end

    it "assigns the second team member to @member_2" do
      subject
      assert(user2 == assigns(:member_2))
    end

    it "checks authorization" do
      controller.should_receive(:authorize!).with(:read, team)
      subject
    end
  end

  describe "GET 'edit'" do
    let(:team) { create(:team) }
    before { user.add_role :owner, team }
    subject { get :edit, id: team.id }

    it "finds the team" do
      subject
      assert(team == assigns(:team))
    end

    it "checks authorization" do
      controller.should_receive(:authorize!).with(:update, team)
      subject
    end

    it "renders the :edit template" do
      subject
      expect(response).to render_template :edit
    end
  end

  describe "PATCH 'update'" do
    let(:team) { create(:team, name: "Team Rocket") }
    let(:name) { "Brotherhood of Evil Mutants" }
    let(:params) { { name: name } }
    before { user.add_role :owner, team }
    subject { patch :update, id: team.id, team: params }

    it "stores the requested team" do
      subject
      assert(team == assigns(:team))
    end

    it "checks authorization" do
      controller.should_receive(:authorize!).with(:update, team)
      subject
    end

    context "with valid attributes" do
      it "updates the task in the database" do
        subject
        expect(team.reload.name).to eq(name)
      end

      it "raises an exception when the update is unsuccessful" do
        Team.stub(:find_and_update).and_raise(Exception)
        assert_raises(Exception) { subject }
      end

      it "sets the flash" do
        subject
        assert("Awesomesauce! Team successfully updated." == flash[:notice])
      end

      it "redirects to the team" do
        subject
        assert_redirected_to team_path(team)
      end
    end

    context "with invalid attributes" do
      let(:params) { { name: "" } }

      it "does not update the team in the database" do
        expect { subject }.to_not change(team, :name)
        assert("Team Rocket" == team.reload.name)
      end

      it "sets the flash" do
        subject
        assert("Do not pass Go. Do not collect $200. JK, change something and try it again." == flash[:error])
      end

      it "re-renders the :edit template" do
        subject
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE 'destroy'" do
    let!(:team) { create(:team) }
    before { user.add_role :owner, team }
    subject { delete :destroy, id: team.id }

    it "checks authorization before deleting the team" do
      controller.should_receive(:authorize!).with(:destroy, team)
      subject
    end

    it "destroys the team" do
      expect { subject }.to change(Team, :count).by(-1)
    end

    it "sets the flash" do
      subject
      assert("Cool beans. Team successfully deleted." == flash[:notice])
    end

    it "redirects to the teams index" do
      subject
      assert_redirected_to teams_path
    end
  end
end
