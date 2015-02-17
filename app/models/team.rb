class Team < ActiveRecord::Base
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships
  has_many :team_membership_invitations, dependent: :destroy
  has_many :scores, dependent: :destroy

  validates_presence_of :name

  default_scope { order("created_at ASC") }

  scope :with_member, -> (user_id) { joins(:members).where("users.id = ?", user_id) }

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
