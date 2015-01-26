class CreateTaskIcons < ActiveRecord::Migration
  def change
    create_table :task_icons do |t|
      t.string :file_name

      t.timestamps
    end
  end
end
