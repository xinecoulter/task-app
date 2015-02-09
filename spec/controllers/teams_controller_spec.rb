require "rails_helper"

describe TeamsController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET 'index'" do
    let(:team1) { create(:team) }
    let(:team2) { create(:team) }
    before do
      team1.members << user
      team2.members << user
    end
    subject { get :index }

    it "assigns the user's teams to @teams" do
      subject
      assert(user.teams == assigns[:teams])
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
    before { user.add_role :owner, team }
    subject { get :show, id: team.id }

    it "it assigns the requested team to @team" do
      subject
      expect(assigns(:team)).to eq team
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

end
