class AddTaskIconIdOnTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :task_icon_id, :integer
  end
end
