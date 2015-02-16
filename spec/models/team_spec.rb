require "rails_helper"

describe Team do
  it "can be created" do
    team = build(:team)
    team.save!
    expect(team).to be_persisted
    expect(team.class).to eq(Team)
  end

  it "must have a name" do
    team = build(:team, name: nil)
    expect { team.save! }.to raise_error
  end

  describe "scope methods" do
    describe "default scope" do
      let!(:team1) { create(:team, created_at: 5.days.ago) }
      let!(:team2) { create(:team, created_at: 2.days.from_now) }
      let!(:team3) { create(:team, created_at: Date.today) }

      it "orders by created_at in ascending order" do
        assert([team1, team3, team2] == Team.all)
      end
    end

    describe ".with_member" do
      let!(:team1) { create(:team) }
      let!(:team2) { create(:team) }
      let!(:team3) { create(:team) }
      let(:user) { create(:user) }
      before do
        team1.members << user
        team3.members << user
      end
      subject { Team.with_member(user.id) }

      it "includes teams that have the specified user as a member" do
        assert(subject.include?(team1))
        assert(subject.include?(team3))
        assert(!subject.include?(team2))
      end
    end
  end

  describe ".make" do
    let(:user) { create(:user) }
    let(:name) { "Big Hero 6" }
    let(:params) { { name: name } }
    subject { Team.make(user, params) }

    it "makes a new team" do
      expect{ subject }.to change(Team, :count).by(1)
    end

    it "gives the team the specified attributes" do
      team = subject
      assert(team.name == name)
    end

    it "makes the user the owner of the team" do
      team = subject
      assert(user.has_role? :owner, team)
    end

    it "makes the user a member of the team" do
      team = subject
      assert(team.members.include? user)
    end
  end

  describe ".find_and_update" do
    let!(:team) { create(:team, name: "Armed and Hammered") }
    let(:name) { "Weapons of Mass Seduction" }
    let(:params) { { name: name } }
    subject { Team.find_and_update(team.id, params) }

    it "finds and updates the team" do
      expect { subject }.to_not change(Team, :count)
      assert(subject.name = name)
    end
  end
end
