FactoryGirl.define do
  factory :team_membership do
    association :team, factory: :team
    association :member, factory: :user
  end
end
