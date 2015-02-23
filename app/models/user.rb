class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :tasks, dependent: :destroy
  has_many :team_memberships, foreign_key: :member_id, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :outgoing_team_membership_invitations, class_name: "TeamMembershipInvitation",
            foreign_key: :user_id, dependent: :destroy
  has_many :incoming_team_membership_invitations, class_name: "TeamMembershipInvitation",
            foreign_key: :invited_user_id, dependent: :destroy
  has_many :scores, foreign_key: :member_id, dependent: :destroy

  def membership_in(team)
    team_memberships.find_by_team_id(team.id)
  end

  def membership_id(team)
    membership_in(team).try(:id)
  end

  def team_membership_invitations_to(team)
    outgoing_team_membership_invitations.where(team_id: team.id)
  end

  def team_membership_invitation_from(team)
    incoming_team_membership_invitations.find_by_team_id(team.id)
  end

  def invited_to?(team)
    !!team_membership_invitation_from(team)
  end

  def teammates_with?(user)
    teams.with_member(user.id).present?
  end

  def score_in(team)
    scores.find_by_team_id(team.id)
  end

end
