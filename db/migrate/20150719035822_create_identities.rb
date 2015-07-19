class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :name
      t.string :uid
      t.text :token
      t.integer :user_id

      t.timestamps
    end
  end
end
