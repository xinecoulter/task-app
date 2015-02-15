class Team < ActiveRecord::Base
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships
  has_many :team_membership_invitations, dependent: :destroy

  validates_presence_of :name

  default_scope { order("created_at ASC") }

  resourcify

  def self.make(owner, params)
    team = create(params)
    owner.add_role :owner, team
    TeamMembership.make(owner.id, team.id)
    team
  end

  def self.find_and_update(id, params)
    team = find(id)
    team.update(params)
    team
  end
end
