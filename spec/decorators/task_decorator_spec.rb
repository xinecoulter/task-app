require "rails_helper"

describe TaskDecorator do

  describe "#interval_description" do
    subject { task.interval_description }

    context "when the interval_number is 1" do
      context "when the interval_type is 'day'" do
        let(:task) { build_stubbed(:task, interval_number: 1, interval_type: "day").decorate }

        it "is 'daily'" do
          assert("daily" == subject)
        end
      end

      context "when the interval_type is not 'day'" do
        let(:task1) { build_stubbed(:task, interval_number: 1, interval_type: "week").decorate }
        let(:task2) { build_stubbed(:task, interval_number: 1, interval_type: "month").decorate }

        it "is interval_type + 'ly'" do
          assert("weekly" == task1.decorate.interval_description)
          assert("monthly" == task2.decorate.interval_description)
        end
      end
    end

    context "when the interval_number is not 1" do
      let(:task) { build_stubbed(:task, interval_number: 2, interval_type: "day").decorate }

      it "is 'every ' + interval_number + ' ' + interval_type + 's'" do
        assert("every 2 days" == subject)
      end
    end
  end

end
