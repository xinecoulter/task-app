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

  it "must have an estimated_effort" do
    task = build(:task, estimated_effort: nil)
    expect { task.save! }.to raise_error
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
      interval_type: interval_type, estimated_effort: 30 } }
    before do
      Task.any_instance.stub(:calculate_interval) { 86400 }
      Task.any_instance.stub(:calculate_point_worth) { 5 }
    end
    subject { Task.make(user.id, params) }

    it "makes a new task" do
      expect{ subject }.to change(Task, :count).by(1)
    end

    it "gives the task an interval" do
      task = subject
      assert(86400 == task.interval)
    end

    it "gives the task the specified attributes" do
      task = subject
      assert(task.name == name)
      assert(task.description == description)
      assert(task.interval_number == interval_number.to_i)
      assert(task.interval_type == interval_type)
    end

    it "gives the task a point_value" do
      task = subject
      assert(5 == task.point_value)
    end
  end

  describe ".find_and_update" do
    let(:user) { create(:user) }
    let!(:task) { create(:task, user: user, name: "Garbage", description: "Take out the garbage!", last_completed_at: nil) }
    let(:name) { "Recycables" }
    let(:description) { "Take out the recycables!" }
    let(:interval_number) { "1" }
    let(:interval_type) { "week" }
    let(:estimated_effort) { "15" }
    let(:params) { { name: name, description: description, interval_number: interval_number,
      interval_type: interval_type, estimated_effort: estimated_effort } }
    before { Task.stub(:find) { task } }
    subject { Task.find_and_update(task.id, params) }

    context "when interval_number and interval_type are included in params" do
      it "sends a message to Task.calculate_interval" do
        task.should_receive(:calculate_interval).with( { new_interval_number: interval_number.to_i,
                                                           new_interval_type: interval_type } )
        subject
      end
    end

    context "when interval_number and interval_type are not included in params" do
      let(:params) { { name: name, description: description } }
      it "does not send a message to Task.calculate_interval" do
        task.should_not_receive(:calculate_interval)
        subject
      end
    end

    context "when estimated_effort is included in params" do
      it "sends a message to Task#calculate_point_worth" do
        task.should_receive(:calculate_point_worth).with(estimated_effort.to_i)
        subject
      end
    end

    context "when estimated_effort is not included in params" do
      let(:params) { { name: name, description: description } }
      it "does not send a message to Task#calculate_point_worth" do
        task.should_not_receive(:calculate_point_worth)
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
        assert(score.reload.points == task.point_value)
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

  describe "#calculate_interval" do
    let(:task) { build(:task, interval_number: 1, interval_type: interval_type) }
    context "when there is no new_interval_number" do
      context "and there is no new_interval_type" do
        subject { task.calculate_interval }
        context "and the interval_type is 'day'" do
          let(:interval_type) { "day" }
          it "multiplies the interval_number by 86400 (seconds)" do
            assert(subject == 86400)
          end
        end
        context "and the interval_type is 'week'" do
          let(:interval_type) { "week" }
          it "multiplies the interval_number by 604800 (seconds)" do
            assert(subject == 604800)
          end
        end
        context "and the interval_type is 'month'" do
          let(:interval_type) { "month" }
          it "multiplies the interval_number 2592000 by (seconds)" do
            assert(subject == 2592000)
          end
        end
      end
      context "and there is a new_interval_type" do
        subject { task.calculate_interval( { new_interval_type: new_interval_type } ) }
        context "and the new_interval_type is 'day'" do
          let(:new_interval_type) { "day" }
          let(:interval_type) { "month" }
          it "multiplies the interval_number by 86400 (seconds) despite the interval_type" do
            assert(subject == 86400)
          end
        end
        context "and the new_interval_type is 'week'" do
          let(:new_interval_type) { "week" }
          let(:interval_type) { "day" }
          it "multiplies the interval_number by 604800 (seconds) despite the interval_type" do
            assert(subject == 604800)
          end
        end
        context "and the new_interval_type is 'month'" do
          let(:new_interval_type) { "month" }
          let(:interval_type) { "week" }
          it "multiplies the interval_number 2592000 by (seconds) despite the interval_type" do
            assert(subject == 2592000)
          end
        end
      end
    end
    context "when there is a new_interval_number" do
      context "and there is no new_interval_type" do
        subject { task.calculate_interval( { new_interval_number: 2 } ) }
        context "and the interval_type is 'day'" do
          let(:interval_type) { "day" }
          it "multiplies the new_interval_number by 86400 (seconds) despite the interval_number" do
            assert(subject == 86400 * 2)
          end
        end
        context "and the interval_type is 'week'" do
          let(:interval_type) { "week" }
          it "multiplies the new_interval_number by 604800 (seconds) despite the interval_number" do
            assert(subject == 604800 * 2)
          end
        end
        context "and the interval_type is 'month'" do
          let(:interval_type) { "month" }
          it "multiplies the new_interval_number 2592000 by (seconds) despite the interval_number" do
            assert(subject == 2592000 * 2)
          end
        end
      end
      context "and there is a new_interval_type" do
        subject { task.calculate_interval( { new_interval_type: new_interval_type, new_interval_number: 2 } ) }
        context "and the new_interval_type is 'day'" do
          let(:new_interval_type) { "day" }
          let(:interval_type) { "month" }
          it "multiplies the new_interval_number by 86400 (seconds) despite the interval_type and interval_number" do
            assert(subject == 86400 * 2)
          end
        end
        context "and the new_interval_type is 'week'" do
          let(:new_interval_type) { "week" }
          let(:interval_type) { "day" }
          it "multiplies the new_interval_number by 604800 (seconds) despite the interval_type and interval_number" do
            assert(subject == 604800 * 2)
          end
        end
        context "and the new_interval_type is 'month'" do
          let(:new_interval_type) { "month" }
          let(:interval_type) { "week" }
          it "multiplies the new_interval_number 2592000 by (seconds) despite the interval_type and interval_number" do
            assert(subject == 2592000 * 2)
          end
        end
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

  describe "#calculate_point_worth" do
    context "when new_estimated_effort is nil" do
      subject { task.calculate_point_worth }
      context "and the estimated_effort is less than or equal to 15" do
        let(:task) { create(:task, estimated_effort: 15) }
        it "is 1" do
          assert(1 == subject)
        end
      end

      context "and the estimated_effort is greater than or equal to 30" do
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
    context "when the new_estimated_effort is not nil" do
      subject { task.calculate_point_worth(new_estimated_effort) }
      context "and the new_estimated_effort is less than or equal to 15" do
        let(:task) { create(:task, estimated_effort: 30) }
        let(:new_estimated_effort) { 15 }
        it "is 1 despite the estimated_effort" do
          assert(1 == subject)
        end
      end
      context "and the new_estimated_effort is greater than or equal to 30" do
        let(:task) { create(:task, estimated_effort: 20) }
        let(:new_estimated_effort) { 30 }
        it "is 5 despite the estimated_effort" do
          assert(5 == subject)
        end
      end
      context "otherwise" do
        let(:task) { create(:task, estimated_effort: 15) }
        let(:new_estimated_effort) { 20 }
        it "is 2 despite the estimated_effort" do
          assert(2 == subject)
        end
      end
    end
  end

end
