class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user

    user_permissions
  end

  def user_permissions
    owner_can [:create,
               :update,
               :destroy] => { Task => :user_id }
  end

  def owner_can(permissions)
    grant(permissions) { |action, thing, key| can action, thing, key => @user.id }
  end

  def grant(permissions)
    permissions.each do |actions, things|
      things.each do |thing|
        actions.each { |action| yield action, *thing }
      end
    end
  end

end
