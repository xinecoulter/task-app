class Team < ActiveRecord::Base
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships

  validates_presence_of :name

  resourcify

  def self.make(owner, params)
    team = new(params)
    team.save
    owner.add_role :owner, team
    team
  end

  def self.find_and_update(id, params)
    team = find(id)
    team.update(params)
    team
  end
end
