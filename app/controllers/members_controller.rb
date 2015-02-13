class MembersController < ApplicationController
  def create
    team = Team.find(params[:team_id])
    membership = authorize_with_transaction!(:create) do
      TeamMembership.make(current_user.id, team.id)
    end

    if membership.valid?
      flash[:notice] = "Challenge accepted! You successfully joined Team #{team.name}."
      current_user.incoming_team_membership_invitations.where(team: team).destroy_all
    else
      flash[:error] = "Oh dear. Something went wrong. How embarrassing."
    end
    redirect_to teams_path
  end

  def destroy
    team = Team.find(params[:team_id])
    membership = TeamMembership.find(params[:id])
    authorize! :destroy, membership
    membership.destroy!

    flash[:notice] = "Aww. Successfully left Team #{team.name}."
    redirect_to teams_path
  end
end
