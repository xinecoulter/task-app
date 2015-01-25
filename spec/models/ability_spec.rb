require "rails_helper"
require "cancan/matchers"

describe Ability do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  subject(:ability) { Ability.new(user) }

  describe "tasks" do
    it "can create and update a task it owns" do
      task = build(:task, user: user)
      expect(ability).to be_able_to(:create, task)
      expect(ability).to be_able_to(:update, task)
    end
    it "cannot create or update a task it does not own" do
      task = build(:task, user: other_user)
      expect(ability).to_not be_able_to(:create, task)
      expect(ability).to_not be_able_to(:update, task)
    end
    it "can destroy a task it owns" do
      task = build(:task, user: user)
      expect(ability).to be_able_to(:destroy, task)
    end
    it "cannot destroy a task it does not own" do
      task = build(:task, user: other_user)
      expect(ability).to_not be_able_to(:destroy, task)
    end
  end
end
