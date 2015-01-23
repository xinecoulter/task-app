FactoryGirl.define do
  sequence(:random_task_desc) {|n| Forgery(:lorem_ipsum).words(10) }

  factory :task do
    association :user
    sequence :name do |n|
      "task ##{n}"
    end
    description { generate(:random_task_desc) }
  end
end
