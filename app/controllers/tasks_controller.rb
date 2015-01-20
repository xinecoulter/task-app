class TasksController < ApplicationController
  def new
    @task = Task.new
  end

  def create
    Task.make(current_user.id, task_params)
    redirect_to root_path
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    Task.find_and_update(params[:id], task_params)
    redirect_to root_path
  end

  def destroy
    id = params[:id]
    task = Task.find(id)
    task.destroy!
    redirect_to root_path
  end

private

  def task_params
    params.require(:task).permit(:name, :description, :last_completed_at, :interval_number, :interval_type)
  end
end
