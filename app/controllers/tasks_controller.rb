class TasksController < ApplicationController
  def index
    @tasks = current_user.tasks.decorate
    render :index
  end

  def new
    @task = Task.new(user: current_user)
    @icons = TaskIcon.all
    authorize! :create, @task
  end

  def create
    task = authorize_with_transaction!(:create) do
      Task.make(current_user.id, task_params)
    end
    if task.valid?
      flash[:notice] = "Awesomesauce! Task successfully created."
      redirect_to tasks_path
    else
      @task = Task.new(user: current_user)
      @icons = TaskIcon.all
      flash[:error] = "Do not pass Go. Do not collect $200. JK, change something and try it again."
      render :new
    end
  end

  def edit
    @task = Task.find(params[:id])
    @icons = TaskIcon.all
    authorize! :view_edit, @task
  end

  def update
    @task = Task.find(params[:id])
    task = authorize_with_transaction!(:update) do
      if current_user == @task.user
        Task.find_and_update(params[:id], task_params)
      elsif @task.user.teammates_with?(current_user)
        Task.find_and_update(params[:id], params.require(:task).permit(:last_completed_at))
      end
    end

    redirection = params[:task][:redirection]
    if task.valid? && "dashboard" == redirection
      redirect_to root_path
    elsif task.valid? && "team" == redirection
      team = Team.find(params[:task][:team_id])
      redirect_to team_path(team)
    elsif task.valid?
      flash[:notice] = "Awesomesauce! Task successfully updated."
      redirect_to tasks_path
    else
      @icons = TaskIcon.all
      flash[:error] = "Do not pass Go. Do not collect $200. JK, change something and try it again."
      render :edit
    end
  end

  def destroy
    id = params[:id]
    task = Task.find(id)
    authorize! :destroy, task
    task.destroy!
    flash[:notice] = "Cool beans. Task successfully deleted."
    redirect_to tasks_path
  end

private

  def task_params
    params.require(:task).permit(:name, :description, :last_completed_at, :interval_number, :interval_type,
      :last_completed_at, :task_icon_id)
  end
end
