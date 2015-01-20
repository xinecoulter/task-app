class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.datetime :last_completed_at
      t.integer :interval
      t.integer :user_id

      t.timestamps
    end
  end
end
