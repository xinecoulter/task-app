FactoryGirl.define do
  factory :task_icon, class: TaskIcon do
    sequence :file_name do |n|
      "icon_#{n}.png"
    end
  end
end
