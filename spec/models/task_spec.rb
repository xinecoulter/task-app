require "rails_helper"

describe Task do
  let(:task) { build(:task) }
  it "can be created" do
    task.save!
    expect(task).to be_persisted
    expect(task.class).to eq(Task)
  end

  # describe ".make" do
  #   it "makes a new task" do
  #   end

  #   it "gives the task the specified attributes" do
  #   end
  # end

  # describe ".find_and_update" do
  # end

  # describe ".calculate_interval" do
  # end
end
