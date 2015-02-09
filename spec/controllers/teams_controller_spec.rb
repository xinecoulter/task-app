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
end
