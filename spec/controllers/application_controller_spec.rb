require "rails_helper"

describe ApplicationController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  before { sign_in user }

  describe "#authorize_with_transaction!" do
    let(:the_task) { build(:task, user: user) }
    before { Task.stub(:make) { the_task } }
    subject {
      controller.authorize_with_transaction!(:create) do
        Task.make(user, attributes_for(:task))
      end
    }

    it "opens a transaction" do
      ActiveRecord::Base.should_receive(:transaction)
      subject
    end

    context "when the yield raises an exception" do
      before { Task.stub(:make).and_raise(Exception) }
      it "re-raises the exception" do
        assert_raises(Exception) { subject }
      end
    end

    context "when the yield returns an object" do
      it "checks authorization" do
        controller.should_receive(:authorize!).with(:create, the_task)
        subject
      end

      context "when the authorization succeeds" do
        it "returns the object" do
          assert(the_task == subject)
        end
      end

      context "when the authorization fails" do
        let(:other_user) { create(:user) }
        before { Task.stub(:make) { build(:task, user: other_user) } }
        it "raises an AccessDenied exception" do
          assert_raises(CanCan::AccessDenied) { subject }
        end
      end
    end
  end

end
