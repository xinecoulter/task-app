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
end
