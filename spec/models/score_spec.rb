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

  describe ".find_and_update" do
    let(:other_user) { create(:user) }
    let!(:score) { create(:score, member: user, team: team, points: 2) }
    let(:points) { 15 }
    before { team.members << user }
    subject { Score.find_and_update(score.id, points) }

    context "when the score's team has enough members" do
      before { team.members << other_user }

      it "finds and updates the score points" do
        expect { subject }.to_not change(Score, :count)
        assert(subject.points == 17)
      end
    end

    context "when the score's team does not have enough members" do
      it "does not update the score" do
        expect { subject }.to_not change(Score, :count)
        assert(subject.points != points)
      end
    end
  end

end
