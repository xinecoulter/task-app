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

  it "must have an interval_type of either 'days', 'weeks', 'months'" do
    assert(build(:task, interval_type: "days").valid?)
    assert(build(:task, interval_type: "weeks").valid?)
    assert(build(:task, interval_type: "months").valid?)
    assert(build(:task, interval_type: "years").invalid?)
  end

  describe ".make" do
    let(:user) { create(:user) }
    let(:name) { "Laundry" }
    let(:description) { "Clean and fold laundry!" }
    let(:interval_number) { "2" }
    let(:interval_type) { "weeks" }
    let(:params) { { name: name, description: description, interval_number: interval_number,
      interval_type: interval_type } }
    before { Task.stub(:calculate_interval) { 86400 } }
    subject { Task.make(user.id, params) }

    it "makes a new task" do
      expect{subject}.to change(Task, :count).by(1)
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
    let!(:task) { create(:task, name: "Garbage", description: "Take out the garbage!") }
    let(:name) { "Recycables" }
    let(:description) { "Take out the recycables!" }
    let(:interval_number) { "1" }
    let(:interval_type) { "weeks" }
    let(:params) { { name: name, description: description, interval_number: interval_number,
      interval_type: interval_type } }
    before { Task.stub(:calculate_interval) }
    subject { Task.find_and_update(task.id, params) }

    it "finds and updates the task" do
      expect { subject }.to_not change(Task, :count)
      assert(subject.name = name)
      assert(subject.description = description)
      assert(subject.interval_number = interval_number.to_i)
      assert(subject.interval_type = interval_type)
    end

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
  end

  describe ".calculate_interval" do
    let(:interval_number) { 1 }
    subject { Task.calculate_interval(interval_number, interval_type) }
    context "when interval_type is 'days'" do
      let(:interval_type) { "days" }
      it "multiplies the interval_number by 86400 (seconds)" do
        assert(subject == 86400)
      end
    end
    context "when the interval_type is 'weeks'" do
      let(:interval_type) { "weeks" }
      it "multiplies the interval_number by 604800 (seconds)" do
        assert(subject == 604800)
      end
    end
    context "when the interval_type is 'months'" do
      let(:interval_type) { "months" }
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
end
