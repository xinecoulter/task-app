require "rails_helper"

describe Score do
  let(:user) { create(:user) }
  let(:team) { create(:team) }

  it "can be created" do
    score = build(:score)
    score.save!
    expect(score).to be_persisted
    expect(score.class).to eq(Score)
  end

  it "can have points" do
    assert(build(:score, points: 5).valid?)
    assert(build(:score, points: nil).valid?)
  end

  it "is unique for a given member and team" do
    create(:score, member: user, team: team)
    duplicate = build(:score, member: user, team: team)
    assert(duplicate.invalid?)
  end

  describe ".make" do
    subject { Score.make(user.id, team.id) }

    it "makes a new score with the provided params" do
      score = subject
      assert(score.class == Score)
      assert(score.persisted?)
      assert(team == score.team)
      assert(user == score.member)
    end

    it "saves the new score in the database" do
      expect { subject }.to change(Score, :count).by(1)
    end
  end
end
