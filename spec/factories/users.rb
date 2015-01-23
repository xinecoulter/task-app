FactoryGirl.define do
  factory :user, class: User do
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password "winteriscoming"
  end
end
