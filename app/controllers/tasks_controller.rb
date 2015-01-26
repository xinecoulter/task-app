class TasksController < ApplicationController
  def index
    @tasks = current_user.tasks
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
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @task = Task.find(params[:id])
    @icons = TaskIcon.all
    authorize! :update, @task
  end

  def update
    @task = authorize_with_transaction!(:update) do
      Task.find_and_update(params[:id], task_params)
    end
    if @task.valid?
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    id = params[:id]
    task = Task.find(id)
    authorize! :destroy, task
    task.destroy!
    redirect_to root_path
  end

private

  def task_params
    params.require(:task).permit(:name, :description, :last_completed_at, :interval_number, :interval_type,
      :last_completed_at, :task_icon_id)
  end
end
