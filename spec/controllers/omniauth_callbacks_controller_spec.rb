require 'spec_helper'

describe OmniauthCallbacksController do
  include Devise::TestHelpers

  let(:user) { create(:user) }
  before do
    sign_in user
    controller.stub(:current_user) { user }
  end

  describe "GET 'facebook'" do
    let(:name) { "facebook" }
    let(:uid) { "abracadabra" }
    let(:token) { "token" }
    let(:credentials) { double(token: token) }
    let(:auth) { double(provider: name, uid: uid, credentials: credentials) }
    let(:identity) { create(:identity, name: name, uid: uid, user: user) }
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      request.env["omniauth.auth"] = auth
      user.stub(:add_identity) { identity }
    end
    subject { get :facebook }

    it "redirects to edit_user_registration_path" do
      subject
      assert_redirected_to edit_user_registration_path
    end

    context "when the identity is persisted" do
      before { identity.stub(:persisted?) { true } }

      it "sets the flash" do
        subject
        assert("Awesomesauce! #{name.titleize} account linked." == flash[:notice])
      end
    end

    context "when the identity is not persisted" do
      before { identity.stub(:persisted?) { false } }

      it "sets the flash" do
        subject
        assert("Womp, womp. Something went wrong." == flash[:error])
      end
    end
  end
end
