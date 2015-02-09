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
