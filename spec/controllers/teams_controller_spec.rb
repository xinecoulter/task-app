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
end
