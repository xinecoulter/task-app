require "rails_helper"

describe TasksController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET 'index'" do
    subject { get :index }

    it "stores the user's tasks as @tasks" do
      subject
      assert(user.tasks == assigns(:tasks))
    end

    it "renders the :index template" do
      subject
      expect(response).to render_template :index
    end
  end

  describe "GET 'new'" do
    subject { get :new }

    it "checks authorization" do
      new_task = build(:task)
      Task.stub(:new) { new_task }
      controller.should_receive(:authorize!).with(:create, new_task)
      subject
    end

    it "renders the :new template" do
      subject
      expect(response).to render_template :new
    end
  end

  describe "POST 'create'" do
    let(:params) { {name: "Vacuum", interval_number: "1", interval_type: "weeks" } }
    let(:the_task) { create(:task, name: "Vacuum", interval_number: 1, interval_type: "weeks") }
    subject { post :create, task: params }

    it "checks authorization" do
      Task.stub(:make) { the_task }
      controller.should_receive(:authorize!).with(:create, the_task)
      subject
    end

    context "with valid attributes" do
      it "saves the new task in the database" do
        expect { subject }.to change(Task, :count).by(1)
      end

      it "redirects to the root" do
        subject
        assert_redirected_to root_path
      end
    end

    context "with invalid attributes" do
      let(:params) { { name: nil, interval_number: "1", interval_type: "weeks" } }

      it "does not save the new task in the database" do
        expect { subject }.to_not change(Task, :count)
      end

      it "re-renders the :new template" do
        subject
        expect(response).to render_template :new
      end
    end
  end

  describe "GET 'edit'" do
    let(:task) { create(:task, user: user) }
    subject { get :edit, id: task.id }

    it "finds the task" do
      subject
      assert(task == assigns(:task))
    end

    it "checks authorization" do
      controller.should_receive(:authorize!).with(:update, task)
      subject
    end

    it "renders the :edit template" do
      subject
      expect(response).to render_template :edit
    end
  end

  describe "PATCH 'update'" do
    let(:task) { create(:task, user: user) }
    let(:params) { { name: "Pay rent", interval_number: "1", interval_type: "months" } }
    subject { patch :update, id: task.id, task: params }

    it "checks authorization" do
      controller.should_receive(:authorize!).with(:update, task)
      subject
    end

    it "stores the requested task" do
      subject
      assert(task == assigns(:task))
    end

    context "with valid attributes" do
      it "updates the task in the database" do
        subject
        expect(task.reload.name).to eq("Pay rent")
      end

      it "raises an exception when the update is unsuccessful" do
        Task.stub(:find_and_update).and_raise(Exception)
        assert_raises(Exception) { subject }
      end

      it "redirects to the root" do
        subject
        assert_redirected_to root_path
      end
    end

    context "with invalid attributes" do
      let(:params) { { name: "Check mail", interval_number: nil, interval_type: "months" } }

      it "does not update the task in the database" do
        expect { subject }.to_not change(task, :name)
        assert("Check mail" != task.reload.name)
      end

      it "re-renders the :edit template" do
        subject
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE 'destroy'" do
    let!(:task) { create(:task, user: user) }
    subject { delete :destroy, id: task.id }

    it "checks authorization before deleting the task" do
      controller.should_receive(:authorize!).with(:destroy, task)
      subject
    end

    it "destroys the task" do
      expect { subject }.to change(Task, :count).by(-1)
    end

    it "redirects to the root" do
      subject
      assert_redirected_to root_path
    end
  end
end
