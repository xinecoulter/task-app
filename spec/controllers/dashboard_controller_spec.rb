require "rails_helper"

describe DashboardController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET 'show'" do
    let!(:task1) { create(:task, user: user) }
    let!(:task2) { create(:task, user: user) }
    subject { get :show }

    it "stores the user's tasks as @tasks" do
      subject
      assert(user.tasks == assigns(:tasks))
    end

    it "renders the :show template" do
      subject
      expect(response).to render_template :show
    end
  end
end
