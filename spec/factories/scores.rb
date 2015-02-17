FactoryGirl.define do
  factory :score do
    association :member, factory: :user
    association :team
    sequence :points do |n|
      n
    end
  end
end
