FactoryGirl.define do
  factory :team_membership_invitation do
    association :user
    association :invited_user, factory: :user
    association :team
  end
end
