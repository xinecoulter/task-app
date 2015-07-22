require "rails_helper"

describe UserDecorator do
  describe "#team_result_message" do
    let(:user) { create(:user).decorate }
    let(:other_user) { create(:user) }
    let(:team) { create(:team) }
    let!(:score_1) { create(:score, points: points, member: user, team: team) }
    let!(:score_2) { create(:score, points: 10, member: other_user, team: team) }
    subject { user.team_result_message(team) }

    context "when the user's score points are higher than the other team member(s) score points" do
      let(:points) { 15 }
      it "returns a string saying the user won" do
        assert("won in this month's chore challenge for #{team.name} in World of WarTask" == subject)
      end
    end
    context "when the user's score points are lower than the other team member(s) score points" do
      let(:points) { 5 }
      it "returns a string saying the user lost" do
        assert("lost in this month's chore challenge for #{team.name} in World of WarTask" == subject)
      end
    end
    context "when the user's score points are equal to the other team member(s) score points" do
      let(:points) { 10 }
      it "returns a string saying the user tied" do
        assert("tied in this month's chore challenge for #{team.name} in World of WarTask" == subject)
      end
    end
  end
end
