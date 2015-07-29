require "rails_helper"

describe UserDecorator do
  describe "#team_result_message" do
    let(:user) { create(:user).decorate }
    let(:other_user) { create(:user).decorate }
    let(:team) { create(:team) }
    let!(:score_1) { create(:score, points: points, member: user, team: team) }
    let!(:score_2) { create(:score, points: 10, member: other_user, team: team) }
    before { team.members << user << other_user }
    subject { user.team_result_message(team) }

    context "when the user's score points are higher than the other team member(s) score points" do
      let(:points) { 15 }
      it "returns a string saying the user won" do
        assert("I won against #{other_user.name} in this month's chore challenge for #{team.name} in World of WarTask!" == subject)
      end
    end
    context "when the user's score points are lower than the other team member(s) score points" do
      let(:points) { 5 }
      it "returns a string saying the user lost" do
        assert("I lost against #{other_user.name} in this month's chore challenge for #{team.name} in World of WarTask!" == subject)
      end
    end
    context "when the user's score points are equal to the other team member(s) score points" do
      let(:points) { 10 }
      it "returns a string saying the user tied" do
        assert("I tied against #{other_user.name} in this month's chore challenge for #{team.name} in World of WarTask!" == subject)
      end
    end
  end

  describe "#name" do
    let(:user) { build(:user, given_name: "Bruce", surname: "Wayne").decorate }
    subject { user.name }

    it "is the user's given_name and surname" do
      assert("#{user.given_name} #{user.surname}" == subject)
    end
  end

  describe "#facebook_name" do
    let(:user) { create(:user, given_name: "George", surname: "Washington").decorate }
    subject { user.facebook_name }

    context "when the user has a facebook identity" do
      let!(:identity) { create(:identity, name: "facebook", given_name: "Thomas", surname: "Jefferson", user: user) }
      it "is the facebook identity's given_name and surname" do
        assert("#{identity.given_name} #{identity.surname}" == subject)
      end
    end
    context "when the user does not have a facebook identity" do
      it "is the user's given_name and surname" do
        assert("#{user.given_name} #{user.surname}" == subject)
      end
    end
  end
end
