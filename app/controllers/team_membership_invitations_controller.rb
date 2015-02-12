class TeamMembershipInvitationsController < ApplicationController
  def index
    @team = Team.find(params[:team_id])
    @team_membership_invitation = TeamMembershipInvitation.new(team_id: @team.id)
    @invitations = current_user.team_membership_invitations_to(@team)
    authorize! :create, @team_membership_invitation
  end

  def create
    invited_user = User.find_by_email(params[:team_membership_invitation][:invited_user_email])
    team = Team.find(params[:team_id])
    invitation = authorize_with_transaction!(:create) do
      TeamMembershipInvitation.make(current_user, invited_user, team)
    end

    if invitation.valid?
      flash[:notice] = "Awesomesauce! Successfully invited #{invited_user.email}."
    else
      flash[:error] = "Do not pass Go. Do not collect $200. JK, change something and try it again."
    end
    redirect_to team_team_membership_invitations_path(team)
  end

  def destroy
    invitation = TeamMembershipInvitation.find(params[:id])
    invited_user = invitation.invited_user
    team = invitation.team

    authorize! :destroy, invitation
    invitation.destroy!

    flash[:notice] = "Cool beans. Successfully uninvited #{invited_user.email}."
    redirect_to team_team_membership_invitations_path(team)
  end
end
