class TeamsController < ApplicationController
  def index
    @teams = current_user.teams
  end

  def new
    @team = Team.new
    authorize! :create, @team
  end

  def create
    @team = authorize_with_transaction!(:create) do
      Team.make(current_user, team_params)
    end
    if @team.valid?
      flash[:notice] = "Awesomesauce! Team #{@team.name} successfully created."
      redirect_to team_path(@team)
    else
      flash[:error] = "Do not pass Go. Do not collect $200. JK, change something and try it again."
      render :new
    end
  end

  def show
    @team = Team.find(params[:id])
    authorize! :read, @team
  end

  def edit
    @team = Team.find(params[:id])
    authorize! :update, @team
  end

  def update
    @team = Team.find(params[:id])
    team = authorize_with_transaction!(:update) do
      Team.find_and_update(params[:id], team_params)
    end
    if team.valid?
      flash[:notice] = "Awesomesauce! Team successfully updated."
      redirect_to team_path(team)
    else
      flash[:error] = "Do not pass Go. Do not collect $200. JK, change something and try it again."
      render :edit
    end
  end

private

  def team_params
    params.require(:team).permit(:name)
  end
end