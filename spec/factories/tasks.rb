FactoryGirl.define do
  sequence(:random_task_desc) {|n| Forgery(:lorem_ipsum).words(10) }

  factory :task do
    association :user
    sequence :name do |n|
      "task ##{n}"
    end
    description { generate(:random_task_desc) }
    sequence :interval_number do |n|
      n
    end
    interval 86400
    interval_type "days"
  end
end
