class Team < ActiveRecord::Base
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships

  validates_presence_of :name
end
