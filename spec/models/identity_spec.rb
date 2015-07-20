require "rails_helper"

describe Identity do
  it "can be created" do
    identity = build(:identity)
    identity.save!
    expect(identity).to be_persisted
    expect(identity.class).to eq(Identity)
  end

  it "can have a name" do
    assert(build(:identity, name: "facebook").valid?)
    assert(build(:identity, name: nil).valid?)
  end

  it "can have a uid" do
    assert(build(:identity, uid: "abcdefgh").valid?)
    assert(build(:identity, uid: nil).valid?)
  end

  it "can have a token" do
    assert(build(:identity, token: "abcdefgh").valid?)
    assert(build(:identity, token: nil).valid?)
  end

  describe ".from_omniauth" do
    let(:name) { "instagraph" }
    let(:uid) { "24601" }
    let(:token) { "token" }
    let(:credentials) { double(token: token) }
    let(:auth) { double(provider: name, uid: uid, credentials: credentials ) }
    subject { Identity.from_omniauth(auth) }

    context "when an identity with the auth provider and uid exists" do
      let!(:identity) { create(:identity, name: name, uid: uid) }

      it "returns the existing identity" do
        expect { subject }.to_not change(Identity, :count)
        response = subject
        assert(identity == response)
      end

      it "does not change the identity" do
        assert(token != subject.token)
      end
    end

    context "when an identity with the auth provider and uid does not exist" do
      it "creates a new identity" do
        expect { subject }.to change(Identity, :count)
        response = subject
        assert(name == response.name)
        assert(uid == response.uid)
      end

      it "assigns the token" do
        assert(token == subject.token)
      end
    end
  end

end
