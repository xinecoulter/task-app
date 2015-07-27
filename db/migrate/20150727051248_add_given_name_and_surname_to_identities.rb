class AddGivenNameAndSurnameToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :given_name, :string
    add_column :identities, :surname, :string
  end
end
