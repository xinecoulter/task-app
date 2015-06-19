require "rails_helper"

describe Task do
  it "can be created" do
    task = build(:task)
    task.save!
    expect(task).to be_persisted
    expect(task.class).to eq(Task)
  end

  it "must have a name" do
    task = build(:task, name: nil)
    expect { task.save! }.to raise_error
  end

  it "can have a description" do
    assert(build(:task, description: "You need to do the thing.").valid?)
    assert(build(:task, description: nil).valid?)
  end

  it "can have a last_completed_at" do
    assert(build(:task, last_completed_at: DateTime.now).valid?)
    assert(build(:task, last_completed_at: nil).valid?)
  end

  it "must have an interval" do
    task = build(:task, interval: nil)
    expect { task.save! }.to raise_error
  end

  it "must have an interval_number" do
    task = build(:task, interval_number: nil)
    expect { task.save! }.to raise_error
  end

  it "must have an interval_type" do
    task = build(:task, interval_type: nil)
    expect { task.save! }.to raise_error
  end

  it "must have an interval_type of either 'day', 'week', 'month'" do
    assert(build(:task, interval_type: "day").valid?)
    assert(build(:task, interval_type: "week").valid?)
    assert(build(:task, interval_type: "month").valid?)
    assert(build(:task, interval_type: "year").invalid?)
  end

  describe "default scope" do
    let!(:task1) { create(:task, created_at: 5.days.ago) }
    let!(:task2) { create(:task, created_at: 2.days.from_now) }
    let!(:task3) { create(:task, created_at: Date.today) }

    it "orders by created_at in ascending order" do
      assert([task1, task3, task2] == Task.all)
    end
  end

  describe ".make" do
    let(:user) { create(:user) }
    let(:name) { "Laundry" }
    let(:description) { "Clean and fold laundry!" }
    let(:interval_number) { "2" }
    let(:interval_type) { "week" }
    let(:params) { { name: name, description: description, interval_number: interval_number,
      interval_type: interval_type } }
    before { Task.stub(:calculate_interval) { 86400 } }
    subject { Task.make(user.id, params) }

    it "makes a new task" do
      expect{ subject }.to change(Task, :count).by(1)
    end

    it "sends a message to Task.calculate_interval" do
      Task.should_receive(:calculate_interval).with(interval_number.to_i, interval_type)
      subject
    end

    it "gives the task the specified attributes" do
      task = subject
      assert(task.name == name)
      assert(task.description == description)
      assert(task.interval_number == interval_number.to_i)
      assert(task.interval_type == interval_type)
    end
  end

  describe ".find_and_update" do
    let(:user) { create(:user) }
    let!(:task) { create(:task, user: user, name: "Garbage", description: "Take out the garbage!", last_completed_at: nil) }
    let(:name) { "Recycables" }
    let(:description) { "Take out the recycables!" }
    let(:interval_number) { "1" }
    let(:interval_type) { "weeks" }
    let(:params) { { name: name, description: description, interval_number: interval_number,
      interval_type: interval_type } }
    before { Task.stub(:calculate_interval) }
    subject { Task.find_and_update(task.id, params) }

    context "when interval_number and interval_type are included in params" do
      it "sends a message to Task.calculate_interval" do
        Task.should_receive(:calculate_interval).with(interval_number.to_i, interval_type)
        subject
      end
    end

    context "when interval_number and interval_type are not included in params" do
      let(:params) { { name: name, description: description } }
      it "does not send a message to Task.calculate_interval" do
        Task.should_not_receive(:calculate_interval)
        subject
      end
    end

    context "when last_completed_at is included in params" do
      let(:other_user) { create(:user) }
      let(:team) { create(:team) }
      let!(:score) { create(:score, member: user, team: team, points: 0) }
      let!(:current_time) { DateTime.now }
      let(:params) { { last_completed_at: current_time } }
      before { team.members << user << other_user }

      it "updates the user's scores (other requirements met)" do
        assert(score.points == 0)
        subject
        assert(score.reload.points == 2)
      end

      it "finds and updates the task" do
        expect { subject }.to_not change(Task, :count)
        assert(subject.last_completed_at == params[:last_completed_at])
      end
    end

    context "when last_completed_at is not included in params" do
      it "finds and updates the task" do
        expect { subject }.to_not change(Task, :count)
        assert(subject.name == name)
        assert(subject.description == description)
        assert(subject.interval_number == interval_number.to_i)
        assert(subject.interval_type == interval_type)
      end
    end
  end

  describe ".calculate_interval" do
    let(:interval_number) { 1 }
    subject { Task.calculate_interval(interval_number, interval_type) }
    context "when interval_type is 'day'" do
      let(:interval_type) { "day" }
      it "multiplies the interval_number by 86400 (seconds)" do
        assert(subject == 86400)
      end
    end
    context "when the interval_type is 'week'" do
      let(:interval_type) { "week" }
      it "multiplies the interval_number by 604800 (seconds)" do
        assert(subject == 604800)
      end
    end
    context "when the interval_type is 'month'" do
      let(:interval_type) { "month" }
      it "multiplies the interval_number 2592000 by (seconds)" do
        assert(subject == 2592000)
      end
    end
  end

  describe "#task_due" do
    let!(:current_time) { DateTime.now }
    before { DateTime.stub(:now) { current_time } }
    subject { task.task_due }
    context "when last_completed_at is nil" do
      let(:task) { create(:task, last_completed_at: nil) }
      it "is DateTime.now" do
        assert(current_time == subject)
      end
    end
    context "when last_completed_at is not nil" do
      let(:task) { create(:task, last_completed_at: 1.day.ago) }
      it "is the sum of last_completed_at and interval" do
        assert(task.last_completed_at + task.interval == subject)
      end
    end
  end

  describe "#ready_for_completion?" do
    let(:task) { create(:task) }
    let!(:current_time) { DateTime.now }
    before { DateTime.stub(:now) { current_time } }
    subject { task.ready_for_completion? }
    context "when the task has never been completed" do
      before { task.stub_chain(:last_completed_at, :nil?) { true } }
      it "is true" do
        assert(subject)
      end
    end
    context "when DateTime.now is after when the task is due" do
      before do
        task.stub_chain(:last_completed_at, :nil?) { false }
        task.stub(:task_due) { 1.day.ago }
      end
      it "is true" do
        assert(subject)
      end
    end
    context "when DateTime.now is the same as when the task is due" do
      before do
        task.stub_chain(:last_completed_at, :nil?) { false }
        task.stub(:task_due) { current_time }
      end
      it "is true" do
        assert(subject)
      end
    end
    context "when DateTime.now is before when the task is due" do
      before do
        task.stub_chain(:last_completed_at, :nil?) { false }
        task.stub(:task_due) { 1.day.from_now }
      end
      it "is false" do
        assert(!subject)
      end
    end
  end

  describe "#calculate_points_to_award" do
    let(:current_time) { DateTime.now }
    let(:task) { create(:task) }
    subject { task.calculate_points_to_award(current_time) }

    context "when the current time is more than 24 hours earlier than when the task is due" do
      before { task.stub(:task_due) { current_time + 605000 } }
      it "is 2 times every 24 hours it is early" do
        assert((605000 / 86400) * 2 == subject)
      end
    end

    context "when the current time is not more than 24 hours earlier than when the task is due" do
      before { task.stub(:task_due) { current_time + 86000 } }
      it "is 2" do
        assert(2 == subject)
      end
    end
  end

  describe "#calculate_point_worth" do
    subject { task.calculate_point_worth }
    context "when the estimated effort is less than or equal to 15" do
      let(:task) { create(:task, estimated_effort: 15) }
      it "is 1" do
        assert(1 == subject)
      end
    end

    context "when the estimated effort is greater than or equal to 30" do
      let(:task) { create(:task, estimated_effort: 30) }
      it "is 5" do
        assert(5 == subject)
      end
    end

    context "otherwise" do
      let(:task) { create(:task, estimated_effort: 20) }
      it "is 2" do
        assert(2 == subject)
      end
    end
  end

end
