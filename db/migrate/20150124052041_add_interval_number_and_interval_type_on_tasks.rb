class AddIntervalNumberAndIntervalTypeOnTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :interval_number, :integer
    add_column :tasks, :interval_type, :string
  end
end
