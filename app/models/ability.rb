class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user

    user_permissions
  end

  def user_permissions
    anyone_can [:create] => [Team]

    owner_can [:create,
               :update,
               :destroy,
               :view_edit] => { Task => :user_id },
              [:destroy] => { TeamMembership => :member_id }

    can_with_owner_role [:manage]  => [Team]

    team_permissions
  end

  def team_permissions
    can [:read], Team do |team|
      @user.membership_in(team)
    end
    can [:create, :destroy], TeamMembershipInvitation do |invite|
      @user.has_role? :owner, invite.team
    end
    cannot [:create], TeamMembershipInvitation do |invite|
      invite.team.is_full?
    end
    can [:create], TeamMembership do |membership|
      @user.invited_to?(membership.team)
    end
    cannot [:destroy], TeamMembership do |membership|
      @user.has_role?(:owner, membership.team)
    end
    can [:update], Task do |task|
      task.user.teammates_with?(@user)
    end
  end

  def anyone_can(permissions)
    grant(permissions) { |action, thing| can action, thing }
  end

  def owner_can(permissions)
    grant(permissions) { |action, thing, key| can action, thing, key => @user.id }
  end

  def can_with_owner_role(permissions)
    grant_with_block(permissions) { |obj| @user.has_role? :owner, obj }
  end

  def grant(permissions)
    permissions.each do |actions, things|
      things.each do |thing|
        actions.each { |action| yield action, *thing }
      end
    end
  end

  def grant_with_block(permissions)
    grant(permissions) do |action, thing|
      can(action, thing) { |obj| yield obj }
    end
  end

end
