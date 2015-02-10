class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :tasks
  has_many :team_memberships, foreign_key: :member_id, dependent: :destroy
  has_many :teams, through: :team_memberships

  def membership_in(team)
    team_memberships.find_by_team_id(team.id)
  end

  def membership_id(team)
    membership_in(team).try(:id)
  end
end
