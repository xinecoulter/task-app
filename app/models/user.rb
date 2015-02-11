class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :tasks
  has_many :team_memberships, foreign_key: :member_id, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :outgoing_team_membership_invitations, class_name: "TeamMembershipInvitation",
            foreign_key: :user_id, dependent: :destroy
  has_many :incoming_team_membership_invitations, class_name: "TeamMembershipInvitation",
            foreign_key: :invited_user_id, dependent: :destroy

  def membership_in(team)
    team_memberships.find_by_team_id(team.id)
  end

  def membership_id(team)
    membership_in(team).try(:id)
  end
end
