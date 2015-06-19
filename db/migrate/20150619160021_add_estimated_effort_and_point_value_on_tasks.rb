class AddEstimatedEffortAndPointValueOnTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :estimated_effort, :integer
    add_column :tasks, :point_value, :integer
  end
end
