class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :team_id
      t.integer :member_id
      t.integer :points, default: 0

      t.timestamps
    end
  end
end
