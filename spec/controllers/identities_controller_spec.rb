require "rails_helper"

describe IdentitiesController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  before { sign_in user }

  describe "DELETE 'destroy'" do
    let!(:identity) { create(:identity, user: user) }
    subject { delete :destroy, id: identity.id }

    it "checks authorization before deleting the identity" do
      controller.should_receive(:authorize!).with(:destroy, identity)
      subject
    end

    it "destroys the identity" do
      expect { subject }.to change(Identity, :count).by(-1)
    end

    it "sets the flash" do
      subject
      assert("Successfully removed social media account." == flash[:notice])
    end

    it "redirects to the edit_user_registration_path" do
      subject
      assert_redirected_to edit_user_registration_path
    end
  end
end
