FactoryGirl.define do
  factory :user, class: User do
    given_name "Test"
    surname "User"
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password "winteriscoming"
  end
end
