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
end
