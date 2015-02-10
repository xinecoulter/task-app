class MembersController < ApplicationController
  def create
    team = Team.find(params[:team_id])
    membership = TeamMembership.make(current_user.id, team.id)

    flash[:notice] = "Challenge accepted! You successfully joined Team #{team.name}."
    redirect_to teams_path
  end

end
