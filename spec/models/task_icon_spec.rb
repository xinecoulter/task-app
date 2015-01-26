require "rails_helper"

describe TaskIcon do
  it "can be created" do
    task_icon = build(:task_icon)
    task_icon.save!
    expect(task_icon).to be_persisted
    expect(task_icon.class).to eq(TaskIcon)
  end

  it "must have a file_name" do
    task_icon = build(:task_icon, file_name: nil)
    expect { task_icon.save! }.to raise_error
  end
end
